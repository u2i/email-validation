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

        it 'returns [true, false]' do
          expect(subject.validate_email(email)).to eq [true, false]
        end
      end

      context 'when a validator returns false' do
        class AlwaysFalseDummy < Base
          def perform_validation(email)
            false
          end
        end

        subject { AlwaysFalseDummy.new }

        it 'returns false' do
          expect(subject.validate_email(email)).to eq [false, true]
        end
      end

      context 'when a validator returns true' do
        class AlwaysTrueDummy < Base
          def perform_validation(email)
            true
          end
        end

        subject { AlwaysTrueDummy.new }

        it 'returns true' do
          expect(subject.validate_email(email)).to eq [true, true]
        end
      end
    end
  end
end
