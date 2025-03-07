require "spec_helper"
require "models/valid_against_schema"

RSpec.describe ResidentialPropertyTribunalDecision do
  let(:payload) { FactoryBot.create(:residential_property_tribunal_decision) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:tribunal_decision) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  context "validations" do
    it "is invalid if the tribunal decision sub category does not match up to the tribunal decision category" do
      tribunal_decision.tribunal_decision_category = "rents"
      tribunal_decision.tribunal_decision_sub_category = "tenant-associations---request-for-information"
      expect(tribunal_decision).not_to be_valid
    end
  end
end
