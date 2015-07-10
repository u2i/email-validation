require 'email-validation/strategy'
require 'email-validation/blacklisted_email'
require 'email-validation/config'

module EmailValidation
  INVALID_EMAIL_MESSAGE = "Your email address is invalid. Please <a href='/contact' title='Customer Service'>contact customer service</a> if you need further assistance."
  NOT_VERIFIED_EMAIL_MESSAGE = "Your email address could not be verified. Please <a href='/contact' title='Customer Service'>contact customer service</a> if you need further assistance."

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
