source "https://rubygems.org"

gem "rails", "3.2.17"

gem "airbrake", "3.1.15"
gem "unicorn"

gem "gds-sso", "9.2.4"
gem "plek", "1.7.0"

gem "mongoid", "2.5.2"

gem "generic_form_builder", "0.8.0"
gem "govspeak", "1.5.1"
gem "multi_json", "1.9.0"

if ENV["CONTENT_MODELS_DEV"]
  gem "govuk_content_models", :path => "../govuk_content_models"
else
  gem "govuk_content_models", "8.9.0"
end

group :assets do
  gem "sass-rails", "3.2.6"
  gem "uglifier", ">= 1.3.0"
  gem "govuk_frontend_toolkit", "0.44.0"
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
  gem "timecop"
  gem "poltergeist", "1.5.0"
  gem "webmock", "~> 1.17.4"
end
