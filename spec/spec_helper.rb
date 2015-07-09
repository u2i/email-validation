require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'email-validation'
require 'sqlite3'
require 'shoulda/matchers'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blacklisted_emails, force: true do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "origin"
  end
end
