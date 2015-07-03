require 'email-validation/validators'

module EmailValidation
  class Strategy

    def verify_email(email)
      return false, EmailValidation::incorrect_email_message(email) if BlacklistedEmail.exists?(email)

      email_invalid = validation_chain.reduce(false) do |is_invalid, validator|
        begin
          is_invalid ||= !validator.validate_email(email)
        rescue Stoplight::Error::RedLight
          is_invalid = false
        end
      end

      BlacklistedEmail.create(email: email) if email_invalid

      msg = email_invalid ? EmailValidation::incorrect_email_message(email) : ''

      return !email_invalid, msg
    end

    private

    def validation_chain
      [Validators::KickboxEmailValidator.new(EmailValidation.config.kickbox_api_key),
       Validators::ResolvEmailValidator.new]
    end
  end
end
