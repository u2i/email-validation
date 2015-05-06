Gem::Specification.new do |s|
  s.name        = 'email-validation'
  s.version     = '1.3.0'
  s.date        = '2014-10-20'
  s.summary     = "Scholastic Trade Ruby gem for email validation"
  s.description = "Scholastic Trade Ruby gem for email validation"
  s.authors     = ["Kacper Madej"]
  s.email       = 'kacper.madej@u2i.com'
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/u2i/email-validation'
  s.platform    = Gem::Platform::RUBY

  s.add_dependency 'exception_notification'
  s.add_dependency 'kickbox'
  s.add_dependency 'activerecord','>= 3.0'
  s.add_dependency 'protected_attributes'
  s.add_dependency 'workflow'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'rspec'
end
