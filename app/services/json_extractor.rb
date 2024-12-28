# frozen_string_literal: true

require "mail"
require "nokogiri"
require "httparty"

class JsonExtractor
  class << self
    def call(email_path_or_url)
      raw_email = read_email_file(email_path_or_url)

      parsed_email = Mail.read_from_string(raw_email)

      json_content = find_json_attachment(parsed_email)
      return json_content if json_content

      links = extract_links_from_body(parsed_email)

      links.each do |link|
        if link =~ /\.json(\?.*)?$/i
          downloaded_json = fetch_json(link)

           if downloaded_json
            return downloaded_json
           else
            downloaded_json = follow_indirect_json_link(link)
            return downloaded_json if downloaded_json
           end
        else
          downloaded_json = follow_indirect_json_link(link)
          return downloaded_json if downloaded_json
        end
      end
      nil
    end

    private

    def read_email_file(path_or_url)
      if path_or_url =~ URI::DEFAULT_PARSER.make_regexp
        HTTParty.get(path_or_url).body
      else
        File.read(path_or_url)
      end
    end

    def find_json_attachment(mail_obj)
      mail_obj.attachments.each do |attachment|
        filename = attachment.filename

        if filename && filename.downcase.end_with?(".json")
          begin
            return JSON.parse(attachment.decoded)
          rescue JSON::ParserError
          end
        end
      end
      nil
    end

    def extract_links_from_body(mail_obj)
      body_links = []

      mail_obj.all_parts.each do |part|
        next unless part.mime_type =~ /(text\/plain|text\/html)/

        content = part.decoded.to_s

        found_urls = content.scan(%r{https?://[^\s<]+})
                    .map { |url| url.sub(/[)"'>]+$/, "") }

        body_links.concat(found_urls)
      end

      body_links.uniq
    end

    def fetch_json(url)
      response = HTTParty.get(url)
      JSON.parse(response.body) if response.code == 200
    rescue JSON::ParserError
        nil
    end

    def follow_indirect_json_link(url)
      response = HTTParty.get(url)
      return unless response.code == 200

      doc = Nokogiri::HTML(response.body)

      doc.css('a[href$=".json"]').each do |node|
        json_href = node["href"]

        json_url = json_href.start_with?("http") ? json_href : URI.join(url, json_href).to_s

        downloaded_json = fetch_json(json_url)
        return downloaded_json if downloaded_json
      end

      nil
    rescue => e
      Rails.logger.info "Error following link #{url}: #{e.message}"
      nil
    end
  end
end
