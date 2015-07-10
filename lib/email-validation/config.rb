module EmailValidation
  class Config
    attr_accessor :stoplight_threshold
    attr_accessor :timeout
    attr_accessor :after_error_hook
    attr_accessor :kickbox_api_key

    DEFAULT_TIMEOUT = 60
    DEFAULT_THRESHOLD = 10
    
    INVALID_EMAIL_MESSAGE = "Your email address is invalid. Please <a href='/contact' title='Customer Service'>contact customer service</a> if you need further assistance."
    NOT_VERIFIED_EMAIL_MESSAGE = "Your email address could not be verified. Please <a href='/contact' title='Customer Service'>contact customer service</a> if you need further assistance."

    def initialize
      @stoplight_threshold = 10
      @timeout = 60
      @after_error_hook = ->(e) {}
    end
  end
end
