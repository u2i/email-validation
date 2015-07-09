require_relative './base'
require 'kickbox'

module EmailValidation
  module Validators
    class KickboxEmailValidator < Base
      EMAIL_VALID_RESPONSES = ['deliverable', 'unknown', 'risky']

      def initialize(api_key)
        client = Kickbox::Client.new(api_key)
        @kickbox = client.kickbox
      end

      def perform_validation(email)
        response = @kickbox.verify email

        code = response.code
        case code
        when 200
          body = response.body
          return EMAIL_VALID_RESPONSES.include?(body['result'])
        when 403
          raise EmailValidationApiForbidden.new
        when 500
          raise EmailValidationApiError.new
        else
          raise UnexpectedEmailValidationApiResponse.new, "Unexpected Kickbox response: #{response.inspect}"
        end
      end
    end
  end
end
