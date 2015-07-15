require 'resolv'

module EmailValidation
  module Validators
    class ResolvEmailValidator < Base
      MAJOR_EMAIL_PROVIDERS = %w{gmail.com googlemail.com yahoo.com hotmail.com
      verizon.net live.com outlook.com}

      SMTP_PROTOCOL_PORT = 25
      SMTP_SERVICE_READY = '220'
      RCPT_MAIL_ACTION_OK = '250'
      RCPT_ABORTED_LOCAL_ERROR = '451'
      RCPT_INSUFFICIENT_SYSTEM_STORAGE = '452'

      ACCEPTED_RCPT_ANSWERS = [RCPT_MAIL_ACTION_OK, RCPT_ABORTED_LOCAL_ERROR,
                               RCPT_INSUFFICIENT_SYSTEM_STORAGE]

      TIMEOUT = 5

      def perform_validation(email)
        socket = nil # make the socket variable visible
        begin
          Timeout::timeout(TIMEOUT) do
            mx_domain = email_domain(email)
            email_resources = email_resources_for_domain(mx_domain)

            if email_resources.empty?
              return ::EmailValidation::ValidationResult.new(false, true)
            elsif MAJOR_EMAIL_PROVIDERS.include?(mx_domain)
              mail_server = preferrable_mail_server(email_resources)

              socket = TCPSocket.new(mail_server, SMTP_PROTOCOL_PORT)

              if smtp_host_ready?(socket)
                unless ACCEPTED_RCPT_ANSWERS.include?(email_rcpt_status(email, socket))
                  return ::EmailValidation::ValidationResult.new(false, true, 'Resolv validation failed')
                end
              end
            end
          end
        ensure
          socket.close if socket
        end

        ::EmailValidation::ValidationResult.new(true, true)
      end

      private

      def email_resources_for_domain(mx_domain)
        Resolv::DNS.open.getresources(mx_domain, Resolv::DNS::Resource::IN::MX)
      end

      def email_domain(email)
        email.downcase.split('@').last.strip
      end

      def preferrable_mail_server(email_resources)
        email_resources.min_by(&:preference).exchange.to_s
      end

      def smtp_host_ready?(socket)
        smtp_response = socket.gets
        smtp_response.starts_with?(SMTP_SERVICE_READY)
      end

      def email_rcpt_status(email, socket)
        socket.send('HELO localhost\r\n', 0)
        smtp_response = socket.gets
        socket.send('MAIL FROM: <no-reply@scholastic.com>\r\n', 0)
        smtp_response = socket.gets
        socket.send("RCPT TO: <#{email}>\r\n",0)
        smtp_response = socket.gets
        smtp_response.split(' ').first
      end
    end
  end
end
