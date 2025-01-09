require "spec_helper"
require "models/valid_against_schema"

RSpec.describe DataEthicsGuidanceDocument do
  let(:payload) { FactoryBot.create(:data_ethics_guidance_document) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"
  subject(:document) { described_class.from_publishing_api(payload) }

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end

  describe "validations" do
    it "is valid from the payload" do
      expect(document).to be_valid
    end

    it "is valid if all facets are missing" do
      document.data_ethics_guidance_document_ethical_theme = nil
      document.data_ethics_guidance_document_organisation_alias = nil
      document.data_ethics_guidance_document_project_phase = nil
      document.data_ethics_guidance_document_technology_area = nil
      expect(document).to be_valid
    end
  end
end
