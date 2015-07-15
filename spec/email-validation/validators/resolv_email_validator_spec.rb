require 'spec_helper'

module EmailValidation
  module Validators
    describe ResolvEmailValidator do
      subject { ResolvEmailValidator.new }

      describe '#perform_validation' do
        let(:result) { subject.perform_validation(email) }
        let(:resources) { [Resolv::DNS::Resource::IN::MX.new(30, Resolv::DNS::Name.create('alt3.gmail-smtp-in.l.google.com'))] }
        let(:socket_double) { double('TCPSocket', close: true) }

        before do
          allow(subject).to receive(:email_resources_for_domain).and_return resources
          allow(TCPSocket).to receive(:new).and_return socket_double
        end

        context 'when the email is in the list of major email providers' do
          before do
            allow(subject).to receive(:smtp_host_ready?).and_return host_ready
            allow(subject).to receive(:email_rcpt_status).and_return rcpt_status
          end

          let(:host_ready) { true }

          context 'when the email exists' do
            let(:email) { 'iexist@gmail.com' }
            let(:host_ready) { true }
            let(:rcpt_status) { ResolvEmailValidator::RCPT_MAIL_ACTION_OK }

            it 'returns a successful validation result' do
              expect(result.valid?).to eq true
              expect(result.success).to eq true
            end
          end

          context 'when the email doesnt exist' do
            let(:email) { 'idontexist@gmail.com' }
            let(:host_ready) { true }
            let(:rcpt_status) { '500' }

            it 'returns a successful validation result' do
              expect(result.valid?).to eq false
              expect(result.success).to eq true
            end
          end

          context 'when something goes bad' do
            let(:email) { 'iexist@gmail.com' }
            let(:rcpt_status) { '123' }

            it 'raises an exception' do
              expect(subject).to receive(:smtp_host_ready?).and_raise(Timeout::Error)
              expect(socket_double).to receive(:close)

              expect { result }.to raise_error(Timeout::Error)
            end
          end
        end

        context 'when the email is not in the list of major email providers' do
          context 'when the email domain exists' do
            let(:email) { 'iexist@existing-email-provider.com' }
            let(:resources) { [Resolv::DNS::Resource::IN::MX.new(30, Resolv::DNS::Name.create('smtp.existing-email-provider.com'))] }

            it 'returns validation result' do
              expect(result.valid?).to eq true
              expect(result.success).to eq true
            end
          end

          context 'when the email domain doesnt exist' do
            let(:email) { 'iexist@not-really.com' }
            let(:resources) { [] }

            it 'returns validation result' do
              expect(result.valid?).to eq false
              expect(result.success).to eq true
            end
          end
        end
      end
    end
  end
end
