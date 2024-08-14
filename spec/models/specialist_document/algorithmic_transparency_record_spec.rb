require "spec_helper"
require "models/valid_against_schema"

RSpec.describe SpecialistDocument::AlgorithmicTransparencyRecord do
  let(:payload) { FactoryBot.create(:algorithmic_transparency_record) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:algorithmic_transparency_record) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(algorithmic_transparency_record).to be_valid
    end

    it "is invalid if the organisation is missing" do
      algorithmic_transparency_record.algorithmic_transparency_record_organisation = nil
      expect(algorithmic_transparency_record).not_to be_valid
    end

    it "is invalid if the organisation type is missing" do
      algorithmic_transparency_record.algorithmic_transparency_record_organisation_type = nil
      expect(algorithmic_transparency_record).not_to be_valid
    end

    it "is invalid if the phase is missing" do
      algorithmic_transparency_record.algorithmic_transparency_record_phase = nil
      expect(algorithmic_transparency_record).not_to be_valid
    end

    it "is invalid if the date published is missing" do
      algorithmic_transparency_record.algorithmic_transparency_record_date_published = nil
      expect(algorithmic_transparency_record).not_to be_valid
    end

    it "is invalid if the ATRS version is missing" do
      algorithmic_transparency_record.algorithmic_transparency_record_atrs_version = nil
      expect(algorithmic_transparency_record).not_to be_valid
    end
  end
end
