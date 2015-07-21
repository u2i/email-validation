module EmailValidation
  class Config
    attr_accessor :stoplight_threshold
    attr_accessor :timeout
    attr_accessor :after_error_hook
    attr_accessor :kickbox_api_key
    attr_accessor :baunced_or_blacklisted_email_message
    attr_accessor :not_verified_email_message

    DEFAULT_TIMEOUT = 60
    DEFAULT_THRESHOLD = 10

    def initialize
      @stoplight_threshold = 10
      @timeout = 60
      @after_error_hook = ->(e) {}
      @baunced_or_blacklisted_email_message = "Your email address is invalid. Please <small><a href='/contact' title='Customer Service'>contact customer service</a></small> if you need further assistance."
      @not_verified_email_message = "Your email address could not be verified. Please <small><a href='/contact' title='Customer Service'>contact customer service</a></small> if you need further assistance."
    end
  end
end
