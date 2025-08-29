require "spec_helper"
require "models/valid_against_schema"

RSpec.describe DefraApprovedAppliance do
  let(:payload) { FactoryBot.create(:defra_approved_appliance) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:defra_approved_appliance) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(defra_approved_appliance).to be_valid
    end

    it "is valid if the Date authorised is a valid date" do
      defra_approved_appliance.defra_approved_appliance_fuel_authorised_date = "2023-01-01"
      expect(defra_approved_appliance).to be_valid
    end

    it "is valid if the Date authorised is not provided" do
      defra_approved_appliance.defra_approved_appliance_fuel_authorised_date = nil
      expect(defra_approved_appliance).to be_valid
    end

    it "is invalid if the Date authorised is not a valid date" do
      defra_approved_appliance.defra_approved_appliance_fuel_authorised_date = "invalid_date"
      expect(defra_approved_appliance).not_to be_valid
    end

    it "is invalid if the appliance name is missing" do
      defra_approved_appliance.defra_approved_appliance_name = nil
      expect(defra_approved_appliance).not_to be_valid
    end

    it "is invalid if the appliance type is missing" do
      defra_approved_appliance.defra_approved_appliance_type = nil
      expect(defra_approved_appliance).not_to be_valid
    end

    it "is invalid if the fuel type is missing" do
      defra_approved_appliance.defra_approved_appliance_fuel_type = nil
      expect(defra_approved_appliance).not_to be_valid
    end

    it "is invalid if the manufacturer is missing" do
      defra_approved_appliance.defra_approved_appliance_manufacturer = nil
      expect(defra_approved_appliance).not_to be_valid
    end

    it "is invalid if the country is missing" do
      defra_approved_appliance.defra_approved_appliance_country = nil
      expect(defra_approved_appliance).not_to be_valid
    end
  end
end
