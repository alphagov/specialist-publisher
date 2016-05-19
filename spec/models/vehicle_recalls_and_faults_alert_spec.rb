require 'spec_helper'
require 'models/valid_against_schema'

RSpec.describe VehicleRecallsAndFaultsAlert do
  let(:payload) { Payloads.vehicle_recalls_and_faults_alert_content_item }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
end
