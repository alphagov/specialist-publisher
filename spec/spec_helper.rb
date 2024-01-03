$LOAD_PATH << File.join(File.dirname(__FILE__), "..")

require "simplecov"
SimpleCov.start "rails"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

require "rspec/rails"
require "fixtures/factories"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join("../../app/lib/*.rb")].sort.each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("features/support/**/*_helpers.rb")]
  .reject { |f| f =~ %r{/api_helpers.rb$} }
  .sort
  .each { |f| require f }

# Quiet down now Mongo
Mongo::Logger.logger.level = ::Logger::FATAL

require "database_cleaner/mongoid"
DatabaseCleaner.strategy = :deletion
DatabaseCleaner.clean

require "services"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/email_alert_api"

require "pundit/rspec"

require "govuk_sidekiq/testing"
Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.before(:each) do
    User.destroy_all
  end

  config.after(:each) do
    Timecop.return
    GDS::SSO.test_user = nil
  end

  config.include Capybara::DSL, type: :feature
  config.include(GdsApi::TestHelpers::PublishingApi)
  config.include(GdsApi::TestHelpers::EmailAlertApi)

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
