source 'https://rubygems.org'

gem 'rails', '5.0.0.1'

gem 'airbrake', '~> 5.5'
gem 'airbrake-ruby', '1.5'
gem 'logstasher', '0.6.2'
gem 'unicorn', '~> 4.9.0'
gem 'sass-rails', '~> 5.0.4'
gem 'mongoid', '~> 6.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails', '~> 4.1.1'
gem 'select2-rails', '~> 3.5.9'
gem 'govuk_sidekiq', '~> 0.0.4'
gem "kaminari"
gem 'kaminari-mongoid'
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'pundit'
gem 'hashdiff'
# GDS managed dependencies
gem 'plek', '~> 1.10'
gem 'gds-sso', '13.0.0'
gem 'govuk_admin_template', '~> 4.4.1'
gem "govuk_frontend_toolkit", "0.44.0"

if ENV["GOVSPEAK_DEV"]
  gem "govspeak", path: "../govspeak"
else
  gem "govspeak", "~> 5.0.1"
end

if ENV["API_DEV"]
  gem "gds-api-adapters", path: "../gds-api-adapters"
else
  gem "gds-api-adapters", "37.5.0"
end

group :development, :test do
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'pry-rails'
  gem 'foreman', '0.74.0'
  gem 'rspec-rails', '~> 3.3'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'database_cleaner', '1.5.1'
  gem 'factory_girl'
  gem "capybara", "2.7.1"
  gem 'capybara-webkit', '1.11.1'
  gem 'timecop', '0.8.0'
  gem 'govuk-content-schema-test-helpers', '1.4.0'
  gem 'govuk-lint'
end

group :test do
  gem 'webmock'
  gem 'rails-controller-testing'
end
