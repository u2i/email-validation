require 'email-validation/validators'

module EmailValidation
  class Strategy

    def verify_email(email)
      return false, EmailValidation::incorrect_email_message(email) if BlacklistedEmail.exists?(email)

      email_valid = true

      validation_chain.each do |validator|
        begin
          email_valid, success = validator.validate_email(email)
          break if success
        rescue Stoplight::Error::RedLight
          next
        end
      end

      BlacklistedEmail.create(email: email) unless email_valid

      msg = email_valid ? '' : EmailValidation::incorrect_email_message(email)

      return email_valid, msg
    end

    private

    def validation_chain
      [Validators::KickboxEmailValidator.new(EmailValidation.config.kickbox_api_key),
       Validators::ResolvEmailValidator.new]
    end
  end
end
