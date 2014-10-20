require 'email_validation_strategy'

describe EmailValidationStrategy do
  describe "#verify_email" do
    let(:email) { "test@test.com" }
    let(:api_key) { "123-api-key" }

    it "uses Kickbox" do
      expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email)
      subject.verify_email(email, api_key)
    end

    it "falls back to Resolv when we run out of credits in Kickbox" do
      expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email).and_raise(EmailValidationApiForbidden)
      expect_any_instance_of(ResolvEmailValidator).to receive(:validate_email).with(email)

      subject.verify_email(email, api_key)
    end

    it "falls back to Resolv when there's an error in Kickbox" do
      expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email).and_raise(EmailValidationApiError)
      expect_any_instance_of(ResolvEmailValidator).to receive(:validate_email).with(email)

      subject.verify_email(email, api_key)
    end

    it "notifies an exception when there's an unknown error in Kickbox" do
      expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email).and_raise(UnexpectedEmailValidationApiResponse)
      expect_any_instance_of(ResolvEmailValidator).to receive(:validate_email).with(email)
      expect(ExceptionNotifier).to receive(:notify_exception)

      subject.verify_email(email, api_key)
    end

  end
end
