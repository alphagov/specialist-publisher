require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe AsylumSupportDecision do
  let(:payload) { FactoryGirl.create(:asylum_support_decision) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
