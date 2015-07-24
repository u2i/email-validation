[![Build Status](https://travis-ci.org/u2i/email-validation.svg)](https://travis-ci.org/u2i/email-validation)
[![Dependency Status](https://gemnasium.com/u2i/email-validation.svg)](https://gemnasium.com/u2i/email-validation)
[![Code Climate](https://codeclimate.com/github/u2i/email-validation/badges/gpa.svg)](https://codeclimate.com/github/u2i/email-validation)
[![Test Coverage](https://codeclimate.com/github/u2i/email-validation/badges/coverage.svg)](https://codeclimate.com/github/u2i/email-validation/coverage)
[![Gem Version](https://badge.fury.io/rb/email-validation.svg)](http://badge.fury.io/rb/email-validation)

email-validation
================

A Ruby Gem that Trade uses to validate emails.


# Usage

1. Put your Kickbox API key in settings under Settings.kickbox.api_key
2. Create a table called blacklisted_emails with fields: 
    email: string
    origin: string
