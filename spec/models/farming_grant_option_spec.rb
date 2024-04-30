require "spec_helper"
require "models/valid_against_schema"

RSpec.describe FarmingGrantOption do
  let(:payload) { FactoryBot.create(:farming_grant_option) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:farming_grant_option) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(farming_grant_option).to be_valid
    end

    it "is invalid if the payment types field is missing" do
      farming_grant_option.payment_types = nil
      expect(farming_grant_option).not_to be_valid
    end
  end
end
