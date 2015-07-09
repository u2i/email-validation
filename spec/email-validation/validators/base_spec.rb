require 'email-validation/validators/base'

module EmailValidation
  module Validators
    describe Base do
      let(:email) { 'example@example.com' }

      context 'when a validator raises an error' do
        class BrokenDummy < Base
          def perform_validation(email)
            fail UnexpectedEmailValidationApiResponse.new
          end
        end

        subject { BrokenDummy.new }

        before do
          @exception = nil

          EmailValidation.config.stoplight_threshold = 1
          EmailValidation.config.after_error_hook = -> (e) do
            @exception = e
          end
        end

        it 'performs an after hook' do
          subject.validate_email(email)

          expect(@exception).to be_a UnexpectedEmailValidationApiResponse
        end

        it 'returns valid: true, success: false' do
          expect(subject.validate_email(email).valid?).to eq true
          expect(subject.validate_email(email).success).to eq false
        end
      end

      context 'when a validator returns false' do
        class AlwaysFalseDummy < Base
          def perform_validation(email)
            ValidationResult.new(false, true)
          end
        end

        subject { AlwaysFalseDummy.new }

        it 'returns valid: false, success: true' do
          expect(subject.validate_email(email).valid?).to eq false
          expect(subject.validate_email(email).success).to eq true
        end
      end

      context 'when a validator returns true' do
        class AlwaysTrueDummy < Base
          def perform_validation(email)
            ValidationResult.new(true, true)
          end
        end
        
        subject { AlwaysTrueDummy.new }

        it 'returns valid: true, success: true' do
          expect(subject.validate_email(email).valid?).to eq true
          expect(subject.validate_email(email).success).to eq true
        end
      end
    end
  end
end
