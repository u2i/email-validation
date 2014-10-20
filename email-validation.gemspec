Gem::Specification.new do |s|
  s.name        = 'email-validation'
  s.version     = '0.0.1'
  s.date        = '2014-10-20'
  s.summary     = "Scholastic Trade Ruby gem for email validation"
  s.description = "Scholastic Trade Ruby gem for email validation"
  s.authors     = ["Kacper Madej"]
  s.email       = 'kacper.madej@u2i.com'
  s.files       = ["lib/email_validation.rb"]
  s.homepage    = 'https://github.com/u2i/email-validation'

  s.add_dependency 'exception_notification'
  s.add_dependency 'settingslogic'
end
