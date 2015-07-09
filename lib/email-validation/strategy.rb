require 'email-validation/validators'

module EmailValidation
  class Strategy

    def verify_email(email)
      return false, EmailValidation::invalid_email_message if BlacklistedEmail.bounce_or_admin.exists?(email)

      validation_result = nil

      validation_chain.each do |validator|
        begin
          validation_result = validator.validate_email(email)
          break if validation_result.success
        rescue Stoplight::Error::RedLight
          next
        end
      end


      validation_result ||= ValidationResult.new(true, true)

      BlacklistedEmail.create(email: email, origin: validation_result.reason) unless validation_result.valid?

      msg = validation_result.valid? ? '' : EmailValidation::incorrect_email_message(email)

      return [validation_result.valid?, msg]
    end

    private

    def validation_chain
      [Validators::KickboxEmailValidator.new(EmailValidation.config.kickbox_api_key),
       Validators::ResolvEmailValidator.new]
    end
  end
end
