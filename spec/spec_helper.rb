$LOAD_PATH << File.join(File.dirname(__FILE__), "..")

require "simplecov"
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

require "rspec/rails"
require "webmock/rspec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("features/support/**/*_helpers.rb")]
  .reject { |f| f =~ %r{/api_helpers.rb$} }
  .each { |f| require f }

require "database_cleaner"
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

RSpec.configure do |config|
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.before(:each, type: :feature) do
    stub_rummager
    stub_publishing_api
    stub_email_alert_api
  end

  config.include Capybara::DSL, type: :feature

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
