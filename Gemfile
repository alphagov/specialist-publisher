source "https://rubygems.org"

gem "rails", "6.0.3.4"

gem "bootstrap-kaminari-views"
gem "fog-aws"
gem "govuk_sidekiq"
gem "hashdiff"
gem "jquery-rails"
gem "kaminari"
gem "kaminari-mongoid"
gem "mail-notify"
gem "mongo"
gem "mongoid"
gem "pundit"
gem "sass-rails"
gem "uglifier"

# v4 changes the generated HTML and breaks the e2e tests
gem "select2-rails", "< 4"

# GDS managed dependencies
gem "gds-api-adapters"
gem "gds-sso"
gem "govspeak"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "govuk_frontend_toolkit"
gem "plek"

group :development do
  gem "listen"
end

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capybara-select-2"
  gem "database_cleaner"
  gem "factory_bot"
  gem "govuk-content-schema-test-helpers"
  gem "govuk_test"
  gem "pry-rails"
  gem "puma"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov", require: false
  gem "timecop"
end

group :test do
  gem "rails-controller-testing"
  gem "webmock"
end
