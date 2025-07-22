source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 8.0.2"

gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "dartsass-rails"
gem "diffy"
gem "gds-api-adapters"
gem "gds-sso"
gem "govspeak"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "hashdiff"
gem "mail-notify"
gem "mongo"
gem "mongoid"
gem "multi_json"
gem "plek"
gem "pundit"
gem "sentry-sidekiq"
gem "stringex"
gem "terser"
gem "view_component"

group :development do
  gem "listen"
end

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "database_cleaner-mongoid"
  gem "factory_bot"
  gem "govuk_schemas"
  gem "govuk_test"
  gem "pry-byebug"
  gem "pry-rails"
  gem "puma"
  gem "rspec-rails"
  gem "rubocop-govuk", require: false
  gem "simplecov", require: false
  gem "timecop"
end

group :test do
  gem "rails-controller-testing"
  gem "webmock"
end
