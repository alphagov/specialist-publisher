require "spec_helper"
require "models/valid_against_schema"

RSpec.describe AuthorisedFuel do
  let(:payload) { FactoryBot.create(:authorised_fuel) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:authorised_fuel) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(authorised_fuel).to be_valid
    end

    it "is invalid if required fields are missing" do
      authorised_fuel.authorised_fuel_name = nil
      authorised_fuel.authorised_fuel_manufacturer_name = nil
      authorised_fuel.authorised_fuel_type = nil
      authorised_fuel.authorised_fuel_country = nil
      authorised_fuel.authorised_fuel_address = nil

      expect(authorised_fuel).not_to be_valid
      expect(authorised_fuel.errors["authorised_fuel_name"]).to eq(["can't be blank"])
      expect(authorised_fuel.errors["authorised_fuel_manufacturer_name"]).to eq(["can't be blank"])
      expect(authorised_fuel.errors["authorised_fuel_type"]).to eq(["can't be blank"])
      expect(authorised_fuel.errors["authorised_fuel_country"]).to eq(["can't be blank"])
      expect(authorised_fuel.errors["authorised_fuel_address"]).to eq(["can't be blank"])
    end
  end
end
