require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe ServiceStandardReport do
  let(:payload) { FactoryGirl.create(:service_standard_report) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
