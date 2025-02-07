require "spec_helper"
require "models/valid_against_schema"

RSpec.describe TrademarkDecision do
  let(:payload) { FactoryBot.create(:trademark_decision) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:trademark_decision) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(trademark_decision).to be_valid
    end

    it "is invalid if the organisation is missing" do
      trademark_decision.trademark_decision_class = nil
      expect(trademark_decision).not_to be_valid
    end
  end
end
