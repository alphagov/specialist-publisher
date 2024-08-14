require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::LifeSavingMaritimeApplianceServiceStation do
  let(:payload) { FactoryBot.create(:life_saving_maritime_appliance_service_station) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    subject { described_class.from_publishing_api(payload) }

    it "is valid for the default factory" do
      expect(subject).to be_valid
    end

    it "is invalid with no region" do
      subject.life_saving_maritime_appliance_service_station_regions = nil
      expect(subject).not_to be_valid
    end

    it "is invalid with no manufacturer" do
      subject.life_saving_maritime_appliance_manufacturer = nil
      expect(subject).not_to be_valid
    end

    it "is valid with no type" do
      subject.life_saving_maritime_appliance_type = nil
      expect(subject).to be_valid
    end
  end
end
