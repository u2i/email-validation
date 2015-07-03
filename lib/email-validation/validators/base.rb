require 'stoplight'
require 'email-validation/config'

module EmailValidation
  module Validators
    class Base
      def validate_email(email)
        raised_error = false

        light = Stoplight(self.class.to_s) { perform_validation(email) }
          .with_threshold(EmailValidation.config.stoplight_threshold)
          .with_timeout(EmailValidation.config.timeout)
          .with_fallback do |e|
            raised_error = true
            EmailValidation.config.after_error_hook.call(e)
          end

        result = light.run
        raised_error ? true : result
      end
    end
  end
end
