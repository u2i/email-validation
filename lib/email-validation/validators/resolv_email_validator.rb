require 'resolv'

module EmailValidation
  module Validators
    class ResolvEmailValidator < Base
      MAJOR_EMAIL_PROVIDERS = %w{gmail.com googlemail.com yahoo.com hotmail.com verizon.net live.com outlook.com}

      def perform_validation(email)
        email.downcase!
        mx_domain = email.split('@').last.to_s.strip
        mail_servers = Resolv::DNS.open.getresources(mx_domain, Resolv::DNS::Resource::IN::MX)

        return false if !mail_servers.nil? && mail_servers.empty?

        if MAJOR_EMAIL_PROVIDERS.include?(mx_domain)
          begin
            mail_server = mail_servers.sort{|a,b| a.preference <=> b.preference}.first.exchange.to_s

            socket = TCPSocket.new(mail_server, 25)
            smtp_response = socket.gets
            if smtp_response.starts_with?('220')
              socket.send("HELO localhost\r\n", 0)
              smtp_response = socket.gets
              socket.send("MAIL FROM: <no-reply@scholastic.com>\r\n", 0)
              smtp_response = socket.gets
              socket.send("RCPT TO: <#{params["user"]["email"]}>\r\n",0)
              smtp_response = socket.gets
              if !smtp_response.starts_with?("250") && !smtp_response.starts_with?("451") && !smtp_response.starts_with?("452")
                return ::EmailValidation::ValidationResult.new(false, true, 'Resolv validation failed')
              end
            end
          rescue => e
            # I'm not sure what we can do here...
          ensure
            socket.close
          end
        end

        return ::EmailValidation::ValidationResult.new(true, true)
      end
    end
  end
end
