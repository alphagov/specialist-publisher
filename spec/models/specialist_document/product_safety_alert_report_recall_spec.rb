require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::ProductSafetyAlertReportRecall do
  let(:payload) { FactoryBot.create(:product_safety_alert_report_recall) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  it "is valid for the default factory" do
    expect(described_class.from_publishing_api(payload)).to be_valid
  end
end
