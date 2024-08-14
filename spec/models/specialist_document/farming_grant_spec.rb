require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::FarmingGrant do
  let(:payload) { FactoryBot.create(:farming_grant) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:farming_grant) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(farming_grant).to be_valid
    end

    it "is invalid if the payment types field is missing" do
      farming_grant.payment_types = nil
      expect(farming_grant).not_to be_valid
    end
  end
end
