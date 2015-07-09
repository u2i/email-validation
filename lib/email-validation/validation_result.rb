module EmailValidation
  class ValidationResult < Struct.new(:valid, :success, :reason)
    def initialize(valid, success, reason=''); super; end

    def valid?
      valid
    end
  end
end
