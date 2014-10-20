require 'exception_notification'
require 'resolv_email_validator'
require 'kickbox_email_validator'

class EmailValidationStrategy
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
