require 'email-validation/strategy'
require 'email-validation/blacklisted_email'
require 'email-validation/config'

module EmailValidation
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
