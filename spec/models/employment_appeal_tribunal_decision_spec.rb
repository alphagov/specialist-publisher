require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe EmploymentAppealTribunalDecision do
  let(:payload) { FactoryGirl.create(:employment_appeal_tribunal_decision) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
