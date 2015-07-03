require 'email-validation'

module EmailValidation
  describe Strategy do
    describe "#verify_email" do
      let(:email) { "test@test.com" }

      context "when the email is blacklisted" do
        before { expect(BlacklistedEmail).to receive(:exists?).and_return(true) }

        it "checks for blacklisted emails first" do
          expect_any_instance_of(Validators::KickboxEmailValidator).not_to receive(:validate_email)

          status, message = subject.verify_email(email)

          expect(message).to eq EmailValidation::incorrect_email_message(email)
          expect(status).to eq false

        end
      end

      context "when the email is not blacklisted" do
        before { expect(BlacklistedEmail).to receive(:exists?).and_return(false) }

        it "uses Kickbox after making sure the email is not blacklisted" do
          expect_any_instance_of(Validators::KickboxEmailValidator).to receive(:perform_validation).with(email).and_return(true)
          subject.verify_email(email)
        end

        it "falls back to Resolv when there's an error in Kickbox" do
          expect_any_instance_of(Validators::KickboxEmailValidator).to receive(:perform_validation).with(email).and_raise(Validators::EmailValidationApiError)
          expect_any_instance_of(Validators::ResolvEmailValidator).to receive(:perform_validation).with(email).and_return true

          subject.verify_email(email)
        end

        it "says the email is valid when Resolv fails" do
          expect_any_instance_of(Validators::KickboxEmailValidator).to receive(:perform_validation).with(email).and_raise(Validators::EmailValidationApiError)
          expect_any_instance_of(Validators::ResolvEmailValidator).to receive(:perform_validation).with(email).and_return(true)

          subject.verify_email(email)
        end
      end

      context "blacklisting emails" do
        before { expect(BlacklistedEmail).to receive(:exists?).and_return(false) }

        context "when the email is invalid" do
          it "blacklists the email" do
            expect_any_instance_of(Validators::KickboxEmailValidator).to receive(:validate_email).with(email).and_return false

            expect(BlacklistedEmail).to receive(:create).with(email: email)

            subject.verify_email(email)
          end
        end

        context "when the email is valid" do
          it "doesn't blacklist the email" do
            expect_any_instance_of(Validators::KickboxEmailValidator).to receive(:validate_email).with(email).and_return true

            expect(BlacklistedEmail).not_to receive(:create).with(email: email)

            subject.verify_email(email)
          end
        end
      end
    end
  end
end
