require "govuk-content-schema-test-helpers"
require "govuk-content-schema-test-helpers/rspec_matchers"

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = "publisher"
  # Can't use Rails.root as this helper is needed for some specs using
  # fast_spec_helper, but that doesn't load Rails.
  config.project_root = File.absolute_path(File.join(File.basename(__FILE__), ".."))
end

RSpec.configuration.include GovukContentSchemaTestHelpers::RSpecMatchers
