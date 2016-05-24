require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe MedicalSafetyAlert do
  let(:payload) { Payloads.medical_safety_alert_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
