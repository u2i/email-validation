require 'email-validation/validators'

module EmailValidation
  class Strategy

    def verify_email(email)
      return false, EmailValidation::INVALID_EMAIL_MESSAGE if BlacklistedEmail.bounce_or_admin?(email)

      validation_result, msg = ValidationResult.new(true, true), ''

      validation_chain.each do |validator|
        begin
          validation_result = validator.validate_email(email)
          break if validation_result.success
        rescue Stoplight::Error::RedLight
          next
        end
      end

      unless validation_result.valid?
        BlacklistedEmail.create(email: email, origin: validation_result.reason)
        msg = EmailValidation::NOT_VERIFIED_EMAIL_MESSAGE
      end

      return [validation_result.valid?, msg]
    end

    private

    def validation_chain
      [Validators::KickboxEmailValidator.new(EmailValidation.config.kickbox_api_key),
       Validators::ResolvEmailValidator.new]
    end
  end
end
