require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::FloodAndCoastalErosionRiskManagementResearchReport do
  let(:payload) { FactoryBot.create(:flood_and_coastal_erosion_risk_management_research_report) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end
end
