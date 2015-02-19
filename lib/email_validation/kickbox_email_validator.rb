require 'kickbox'

module EmailValidation
  class EmailValidationApiForbidden < StandardError; end
  class EmailValidationApiError < StandardError; end
  class UnexpectedEmailValidationApiResponse < StandardError; end

  class KickboxEmailValidator
    def initialize(api_key)
      client = Kickbox::Client.new(api_key)
      @kickbox = client.kickbox
    end

    def validate_email(email)
      return true, "" unless dispatch_request?

      response = @kickbox.verify email

      code = response.code
      case code
      when 200
        body = response.body
        return true, "" if body["result"] == "valid"
        return false, "The email address you have entered (#{email}) is incorrect." if body["result"] != "valid"
      when 403
        raise EmailValidationApiForbidden.new
      when 500
        raise EmailValidationApiError.new
      else
        raise UnexpectedEmailValidationApiResponse.new, "Unexpected Kickbox response: #{response.inspect}"
      end
    end

    private

    def dispatch_request?
      !Rails.env.test?
    end
  end
end
