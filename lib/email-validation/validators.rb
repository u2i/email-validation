require_relative 'validators/base'
require_relative 'validators/kickbox_email_validator'
require_relative 'validators/resolv_email_validator'

module EmailValidation
  module Validators
    class EmailValidationApiForbidden < StandardError; end
    class EmailValidationApiError < StandardError; end
    class UnexpectedEmailValidationApiResponse < StandardError; end
  end
end
