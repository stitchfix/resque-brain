source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jbuilder'
gem 'spring',        group: :development
gem 'bower-rails'
gem 'resque'
gem 'angular-rails-templates'
gem 'puma'
gem "foreman"
gem "cron2english"
gem "rack-timeout"
gem "aws-healthcheck"
gem 'resqutils'
gem 'resque-retry'
gem 'resque-scheduler'
gem 'aws-sdk'
gem 'dalli'
gem 'dogstatsd-ruby'

group :test, :development do
  gem "capybara"
  gem "selenium-webdriver"
  gem "teaspoon-jasmine"
  gem "poltergeist"
  gem "mocha"
end

group :production, :staging do
    gem "rails_12factor"
    gem "rails_stdout_logging"
    gem "rails_serve_static_assets"
    gem 'newrelic_rpm'
end

gem 'nokogiri', '>= 1.8.0'

gem 'rails-html-sanitizer', '~> 1.0.3'
source "https://gem.fury.io/me/" do
  gem "stitchfix-env_management", require: "stitch_fix/env_management", group: [:development, :test]
end
