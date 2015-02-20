require 'exception_notification'
require 'email-validation/resolv_email_validator'
require 'email-validation/kickbox_email_validator'

module EmailValidation
  class Strategy
    def verify_email(email, api_key)
      begin

        if BlacklistedEmail.exists?(email)
          valid_email = false
        else
          valid_email = KickboxEmailValidator.new(api_key).validate_email(email)
        end

      rescue EmailValidationApiForbidden, EmailValidationApiError
        valid_email = ResolvEmailValidator.new.validate_email email

      rescue UnexpectedEmailValidationApiResponse => e
        ExceptionNotifier.notify_exception(e)
        valid_email = ResolvEmailValidator.new.validate_email email
      end

      BlacklistedEmail.create(email: email) unless valid_email

      msg = valid_email ? "" : EmailValidation::incorrect_email_message(email)

      return valid_email, msg
    end
  end
end
