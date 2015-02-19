require 'active_record'
require 'protected_attributes'
require 'workflow'

module EmailValidation
  class BlacklistedEmail < ::ActiveRecord::Base
    self.table_name = 'blacklisted_emails'

    include Workflow
    workflow_column :origin

    attr_accessible :email, :origin

    validates :origin, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: /\A[^\s]+@[^\s]+\z/i }

    before_save :parse_email

    workflow do
      state :bounce
      state :unsubscribe
    end


    def self.exists? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email).exists?
    end

    def self.bounced? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email, origin: "bounce").exists?
    end

    def self.unsubscribed? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email, origin: "unsubscribe").exists?
    end

    protected

    def self.parse_email_address email
      email.gsub(/\+.*@/, "@")
    end

    def parse_email
      self.email = BlacklistedEmail.parse_email_address(self.email)
    end
  end
end
