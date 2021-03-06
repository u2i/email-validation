require 'active_record'
require 'protected_attributes'

module EmailValidation
  class BlacklistedEmail < ::ActiveRecord::Base
    self.table_name = 'blacklisted_emails'

    attr_accessible :email, :origin

    validates :origin, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: /\A[^\s]+@[^\s]+\z/i }

    before_save :parse_email

    ORIGIN_ADMIN = 'admin'
    ORIGIN_BOUNCE = 'bounce'
    ORIGIN_UNSUBSCRIBE = 'unsubscribe'

    def self.bounce_or_admin? email
      email = BlacklistedEmail.parse_email_address(email.to_s)
      BlacklistedEmail.where(email: email, origin: [ORIGIN_BOUNCE, ORIGIN_ADMIN]).exists?
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
