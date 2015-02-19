require 'spec_helper'

describe EmailValidation::BlacklistedEmail do
  before do
    BlacklistedEmail.create(email: "test@test.com")
  end

  it { is_expected.to allow_mass_assignment_of :email }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of :email }
  it { is_expected.to allow_value("example@example.com").for(:email) }
  it { is_expected.to allow_value("1a@a.com").for(:email) }
  it { is_expected.to allow_value("a@2a.net").for(:email) }
  it { is_expected.not_to allow_value("abc").for(:email) }
  it { is_expected.not_to allow_value("s @abc.com").for(:email) }
  it { is_expected.not_to allow_value("a@\td.com").for(:email) }
  it { is_expected.not_to allow_value("a@a.c m").for(:email) }

  describe "#BlacklistedEmail.parse_email_address" do
    it "for a valid email address" do
      expect(BlacklistedEmail.parse_email_address("test@test.com")).to eq("test@test.com")
      expect(BlacklistedEmail.parse_email_address("test.test@test.com")).to eq("test.test@test.com")
    end

    it "for an invalid email address" do
      expect(BlacklistedEmail.parse_email_address("test+123@test.com")).to eq("test@test.com")
      expect(BlacklistedEmail.parse_email_address("test+@test.com")).to eq("test@test.com")
      expect(BlacklistedEmail.parse_email_address("test+@++@@test.com")).to eq("test@test.com")
      expect(BlacklistedEmail.parse_email_address("test+123@@@test.com")).to eq("test@test.com")
      expect(BlacklistedEmail.parse_email_address("test++sfdsgg@+++@test.com")).to eq("test@test.com")
    end
  end

  describe "#parse_email_filter" do
    before do
      @blacklisted = BlacklistedEmail.create(email: "test+123@test.com", origin: "unsubscribe")
    end

    it "should have parsed email" do
      expect(@blacklisted.email).to eq("test@test.com")
    end
  end
end
