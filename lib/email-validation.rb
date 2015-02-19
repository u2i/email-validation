require 'email-validation/strategy'
require 'email-validation/blacklisted_email'

module EmailValidation
  def self.incorrect_email_message(email)
    "The email address you have entered (#{email}) is incorrect."
  end

end
