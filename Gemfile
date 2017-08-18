# frozen_string_literal: true

source 'https://rubygems.org'

gem 'angular-rails-templates', git: 'https://github.com/davetron5000/angular-rails-templates.git', branch: 'patch-1'
gem 'aws-healthcheck'
gem 'aws-sdk'
gem 'bower-rails'
gem 'coffee-rails'
gem 'cron2english'
gem 'dalli'
gem 'foreman'
gem 'jbuilder'
gem 'jquery-rails'
gem 'puma'
gem 'rack-timeout'
gem 'rails', '~> 4.2'
gem 'resque', github: 'resque/resque', branch: 'master' # 'https://github.com/stitchfix/resque.git', branch: 'resque-redis-interface'
gem 'resque-retry'
gem 'resque-scheduler'
gem 'resqutils'
gem 'sass-rails'
gem 'spring', group: :development
gem 'uglifier'

group :test, :development do
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'mocha', require: 'mocha/setup'
  gem 'poltergeist'
  gem 'rubocop', require: false
  gem 'selenium-webdriver'
  gem 'teaspoon-jasmine'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'rails_stdout_logging'
end

gem 'nokogiri', '>= 1.8.0'

gem 'rails-html-sanitizer', '~> 1.0.3'
