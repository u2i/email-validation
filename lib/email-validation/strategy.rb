require 'exception_notification'
require 'email-validation/resolv_email_validator'
require 'email-validation/kickbox_email_validator'

module EmailValidation
  class Strategy
    def verify_email(email, api_key)
      begin
        return KickboxEmailValidator.new(api_key).validate_email(email)
      rescue EmailValidationApiForbidden, EmailValidationApiError
        return ResolvEmailValidator.new.validate_email email
      rescue UnexpectedEmailValidationApiResponse => e
        ExceptionNotifier.notify_exception(e)
        return ResolvEmailValidator.new.validate_email email
      end
    end
  end
end
