require 'email-validation/strategy'
require 'email-validation/blacklisted_email'
require 'email-validation/config'

module EmailValidation
  def self.incorrect_email_message(email)
    "The email address you have entered (#{email}) is incorrect."
  end

  class << self
    attr_writer :config
  end

  def self.config
    @configuration ||= Config.new
  end

  def self.configure
    yield(config)
  end
end
