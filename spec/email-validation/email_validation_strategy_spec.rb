require 'email-validation'

module EmailValidation
  describe Strategy do
    describe "#verify_email" do
      let(:email) { "test@test.com" }
      let(:api_key) { "123-api-key" }

      before { BlacklistedEmail.destroy_all }

      context "when the email is blacklisted" do
        let!(:blacklisted_mail) { BlacklistedEmail.create!(email: email) }

        after { blacklisted_mail.destroy }

        it "checks for blacklisted emails first" do
          expect_any_instance_of(KickboxEmailValidator).not_to receive(:validate_email)

          status, message = subject.verify_email(email, api_key)

          expect(message).to eq EmailValidation::incorrect_email_message(email)
          expect(status).to eq false

        end
      end

      context "when the email is not blacklisted" do
        it "uses Kickbox after making sure the email is not blacklisted" do
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

      context "blacklisting emails" do
        context "when the email is invalid" do
          it "blacklists the email" do
            expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email).and_return false

            expect(BlacklistedEmail).to receive(:create).with(email: email)

            subject.verify_email(email, api_key)
          end
        end

        context "when the email is valid" do
          it "doesn't blacklist the email" do
            expect_any_instance_of(KickboxEmailValidator).to receive(:validate_email).with(email).and_return true

            expect(BlacklistedEmail).not_to receive(:create).with(email: email)

            subject.verify_email(email, api_key)
          end
        end
      end
    end
  end
end
