require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe AaibReport do
  let(:payload) { FactoryGirl.create(:aaib_report) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
