source "https://rubygems.org"

gem "rails", "3.2.17"

# Alphabetical order please :)
gem "airbrake", "3.1.15"
gem "faraday", "0.9.0"
gem "fetchable", "1.0.0"
gem "gds-sso", "9.2.4"
gem "generic_form_builder", "0.8.0"
gem "govspeak", "1.6.2"
gem 'govuk_admin_template', '1.0.0'
gem "logstasher", "0.4.8"
gem "mongoid", "2.5.2"
gem "mongoid_rails_migrations", "1.0.0"
gem "multi_json", "1.9.0"
gem "plek", "1.7.0"
gem "unicorn", "4.8.2"

if ENV["CONTENT_MODELS_DEV"]
  gem "govuk_content_models", :path => "../govuk_content_models"
else
  gem "govuk_content_models", "14.0.0"
end

if ENV["API_DEV"]
  gem "gds-api-adapters", :path => "../gds-api-adapters"
else
  gem "gds-api-adapters", "11.3.0"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :assets do
  gem "sass-rails", "3.2.6"
  gem "uglifier", ">= 1.3.0"
  gem "govuk_frontend_toolkit", "0.44.0"
  gem "select2-rails",  "3.5.9"
end

gem "byebug", group: [:development, :test]
gem "pry", group: [:development, :test]
gem "awesome_print", group: [:development, :test]

group :test do
  gem "cucumber-rails", "1.4.0", require: false
  gem "launchy"
  gem "rspec-rails", "2.14.1"
  gem "factory_girl", "4.3.0"
  gem "database_cleaner", "1.2.0"
  gem "poltergeist", "1.5.0"
  gem "webmock", "~> 1.17.4"
  gem "rubocop"
end

group :development, :test do
  gem "jasmine-rails"
end
