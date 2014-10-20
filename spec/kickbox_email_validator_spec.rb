require 'kickbox_email_validator'

describe KickboxEmailValidator do
  describe "#validate_email" do
    let(:kickbox_double) { double(verify: verify_response) }
    let(:email) { "bill.lumbergh@gmail.com" }
    let(:verify_response) do
      double(code: 200,
             body: {
        "result" => "valid",
        "role" => false,
        "free" => false,
        "disposable" => false,
        "accept_all" => false,
        "did_you_mean" => nil,
        "sendex" => 0.23,
        "email" => "bill.lumbergh@gmail.com",
        "user" => "bill.lumbergh",
        "domain" => "gmail.com",
        "success" => true
      })
    end


    subject { KickboxEmailValidator.new("123-api-key") }

    before do
      subject.instance_variable_set(:@kickbox, kickbox_double)
      allow(subject).to receive(:dispatch_request?).and_return(true)
    end

    context "For a successful response" do
      context "when the email is valid" do
       it "returns [true, '']" do
          expect( subject.validate_email(email) ).to eq( [true, ""] )
        end
      end

      context "when the email is invalid" do
        let(:email) { "bill.lumbergh@gamil.com" }
        let(:verify_response) do
          double(code: 200,
                 body: {
            "result" => "invalid",
            "reason" => "rejected_email",
            "role" => false,
            "free" => false,
            "disposable" => false,
            "accept_all" => false,
            "did_you_mean" => "bill.lumbergh@gmail.com",
            "sendex" => 0.23,
            "email" => "bill.lumbergh@gamil.com",
            "user" => "bill.lumbergh",
            "domain" => "gamil.com",
            "success" => true
          })
        end

        it "returns false and an error message" do
          expect( subject.validate_email(email) ).to eq( [false, "The email address you have entered (#{email}) is incorrect."] )
        end
      end
    end

    context "For forbidden response" do
      let(:verify_response) { double(code: 403) }

      it "throws EmailValidationApiForbidden" do
        expect{ subject.validate_email(email) }.to raise_error(EmailValidationApiForbidden)
      end
    end

    context "For Kickbox server error" do
      let(:verify_response) { double(code: 500) }

      it "throws EmailValidationApiError" do
        expect{ subject.validate_email(email) }.to raise_error(EmailValidationApiError)
      end
    end

    context "For an unexpected response" do
      let(:verify_response) { double(code: 418) } # I'm a teapot

      it "throws UnexpectedEmailValidationApiResponse" do
        expect{ subject.validate_email(email) }.to raise_error(UnexpectedEmailValidationApiResponse)
      end
    end
  end
end
