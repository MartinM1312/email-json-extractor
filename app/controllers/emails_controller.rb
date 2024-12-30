class EmailsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /emails/parse
  def parse
    email_source = params[:email_source]

    begin
      extracted_json = JsonExtractor.call(email_source)

      if extracted_json
        render json: extracted_json, status: :ok
      else
        render json: { error: "No JSON found in the email or link chain" }, status: :not_found
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
