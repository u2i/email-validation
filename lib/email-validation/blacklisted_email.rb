require 'active_record'
require 'protected_attributes'
require 'workflow'

module EmailValidation
  class BlacklistedEmail < ::ActiveRecord::Base
    self.table_name = 'blacklisted_emails'
    scope :bounce_or_admin, -> { where(origin: [ORIGIN_BOUNCE, ORIGIN_ADMIN]) }

    include Workflow
    workflow_column :origin

    attr_accessible :email, :origin

    validates :origin, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: /\A[^\s]+@[^\s]+\z/i }

    before_save :parse_email

    workflow do
      state :bounce
      state :unsubscribe
      state :admin
    end

    ORIGIN_ADMIN = 'admin'
    ORIGIN_BOUNCE = 'bounce'
    ORIGIN_UNSUBSCRIBE = 'unsubscribe'

    def self.exists? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email).exists?
    end

    def self.bounced? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email, origin: ORIGIN_BOUNCE).exists?
    end

    def self.unsubscribed? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email, origin: ORIGIN_UNSUBSCRIBE).exists?
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
