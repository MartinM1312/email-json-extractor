require 'rails_helper'

RSpec.describe "Emails", type: :request do
  describe "POST /emails/parse" do
    let(:fake_email_path) { "/fake/path/to/email.eml" }

    it "returns the JSON if the extractor finds it" do
      allow(JsonExtractor).to receive(:call).and_return({ "test" => "ok" })

      post "/emails/parse", params: { email_source: fake_email_path }
      expect(response).to have_http_status(:ok)

      json_body = JSON.parse(response.body)
      expect(json_body).to eq({ "test" => "ok" })
    end

    it "returns 404 if no JSON is found" do
      allow(JsonExtractor).to receive(:call).and_return(nil)

      post "/emails/parse", params: { email_source: fake_email_path }
      expect(response).to have_http_status(:not_found)

      json_body = JSON.parse(response.body)
      expect(json_body["error"]).to eq("No JSON found in the email or link chain")
    end

    it "returns 422 if an unexpected error occurs" do
      allow(JsonExtractor).to receive(:call).and_raise("Something bad")

      post "/emails/parse", params: { email_source: fake_email_path }
      expect(response).to have_http_status(:unprocessable_entity)

      json_body = JSON.parse(response.body)
      expect(json_body["error"]).to eq("Something bad")
    end
  end
end
