require "spec_helper"
require "spec/exporters/formatters/abstract_indexable_formatter_spec"
require "spec/exporters/formatters/abstract_specialist_document_indexable_formatter_spec"
require "formatters/esi_fund_indexable_formatter"

RSpec.describe VehicleRecallsAndFaultsAlertIndexableFormatter do
  let(:document) {
    double(
      :vehicle_recalls_and_faults_alert,
      body: double,
      slug: double,
      summary: double,
      title: double,
      fault_type: double,
      item_type: double,
      manufacturer: double,
      item_model: double,
      serial_number: double,
      build_start_date: double,
      build_end_date: double,
      alert_issue_date: double,
      updated_at: double,
      minor_update?: false,
    )
  }

  subject(:formatter) { described_class.new(document) }

  it_should_behave_like "a specialist document indexable formatter"

  it "should have a type of vehicle_recalls_and_faults_alert" do
    expect(formatter.type).to eq("vehicle_recalls_and_faults_alert")
  end
end
