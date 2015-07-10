require 'email-validation/strategy'
require 'email-validation/blacklisted_email'
require 'email-validation/config'

module EmailValidation
  def self.invalid_email_message
    "Your email address is invalid. Please #{self.contact_link} if you need further assistance."
  end

  def self.not_verified_email_message
    "Your email address could not be verified. Please #{self.contact_link} if you need further assistance."
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

  def self.contact_link
    "<a href='/contact' title='Customer Service'>contact customer service</a>"
  end
end
