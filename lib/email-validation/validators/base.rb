require 'stoplight'
require 'email-validation/config'

module EmailValidation
  module Validators
    class Base
      def validate_email(email)
        success = true

        light = Stoplight(self.class.to_s) { perform_validation(email) }
          .with_threshold(EmailValidation.config.stoplight_threshold)
          .with_timeout(EmailValidation.config.timeout)
          .with_fallback do |e|
            success = false
            EmailValidation.config.after_error_hook.call(e)
          end

        validation_result = light.run
        success ? validation_result : ::EmailValidation::ValidationResult.new(true, false)
      end
    end
  end
end
