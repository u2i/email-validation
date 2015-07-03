require 'email-validation'

describe EmailValidation do
  describe '#configure' do
    before do
      EmailValidation.instance_variable_set(:@configuration, nil)
    end

    it 'has default values' do
      EmailValidation.configure { |conf| }

      expect(EmailValidation.config.timeout).to eq EmailValidation::Config::DEFAULT_TIMEOUT
      expect(EmailValidation.config.stoplight_threshold).to eq EmailValidation::Config::DEFAULT_THRESHOLD
    end

    it 'sets attributes of a Config object' do
      EmailValidation.configure do |conf|
        conf.timeout = 123
        conf.kickbox_api_key = 'key-123-456'
      end

      expect(EmailValidation.config.timeout).to eq 123
      expect(EmailValidation.config.kickbox_api_key).to eq 'key-123-456'
    end
  end
end
