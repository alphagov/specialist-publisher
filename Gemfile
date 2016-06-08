source 'https://rubygems.org'

gem 'rails', '4.2.6'

gem 'airbrake', '~> 4.2.1'
gem 'logstasher', '0.6.2'
gem 'unicorn', '~> 4.9.0'
gem 'sass-rails', '~> 4.0.3'
gem 'mongoid', '5.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails', '~> 3.1.4'
gem 'select2-rails', '~> 4.0.0'
gem 'sidekiq', '~> 3.5.1'
gem 'sidekiq-logging-json', '~> 0.0.14'
gem "kaminari"
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'pundit'
# GDS managed dependencies
gem 'plek', '~> 1.10'
gem 'gds-sso', '11.0.0'
gem 'govuk_admin_template', '~> 3.4.0'
gem "govuk_frontend_toolkit", "0.44.0"

if ENV["GOVSPEAK_DEV"]
  gem "govspeak", path: "../govspeak"
else
  gem "govspeak", "~> 3.5"
end

if ENV["API_DEV"]
  gem "gds-api-adapters", path: "../gds-api-adapters"
else
  gem "gds-api-adapters", "30.9.0"
end

group :development, :test do
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'pry'
  gem 'foreman', '0.74.0'
  gem 'rspec-rails', '~> 3.3'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'database_cleaner', '1.5.1'
  gem 'factory_girl'
  gem "capybara", "2.5.0"
  gem 'capybara-webkit', '1.7.1'
  gem 'timecop', '0.8.0'
  gem 'govuk-content-schema-test-helpers', '1.4.0'
  gem 'govuk-lint'
end

group :test do
  gem 'webmock'
end
