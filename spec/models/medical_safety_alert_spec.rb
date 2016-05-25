require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe MedicalSafetyAlert do
  let(:payload) { FactoryGirl.create(:medical_safety_alert) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
