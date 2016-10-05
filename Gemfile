source 'https://rubygems.org'

gem 'rails', '~> 4.2.7.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'spring',        group: :development
gem 'bower-rails'
gem 'resque', github: 'resque/resque', branch: 'master'#'https://github.com/stitchfix/resque.git', branch: 'resque-redis-interface'
gem 'angular-rails-templates', git: "https://github.com/davetron5000/angular-rails-templates.git", branch: "patch-1"
gem 'unicorn'
gem "foreman"
gem "cron2english"

group :test, :development do
  gem "capybara"
  gem "selenium-webdriver"
  gem "teaspoon-jasmine"
  gem "dotenv-rails"
  gem "poltergeist"
end

group :production, :staging do
    gem "rails_12factor"
    gem "rails_stdout_logging"
    gem "rails_serve_static_assets"
end

gem 'nokogiri', '>= 1.6.7.2'

gem 'rails-html-sanitizer', '~> 1.0.3'
