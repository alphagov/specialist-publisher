require 'spec_helper'

RSpec.describe DocumentLinksPresenter do
  document_types = {
    DfidResearchOutput => 'db994552-7644-404d-a770-a2fe659c661f',
    EmploymentTribunalDecision => '6f757605-ab8f-4b62-84e4-99f79cf085c2',
    AaibReport => "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4",
    CmaCase => "fef4ac7c-024a-4943-9f19-e85a8369a1f3",
    EmploymentAppealTribunalDecision => '6f757605-ab8f-4b62-84e4-99f79cf085c2',
    MaibReport => "9c66b9a3-1e6a-48e8-974d-2a5635f84679",
    EsiFund => "2e7868a8-38f5-4ff6-b62f-9a15d1c22d28",
    TaxTribunalDecision => '6f757605-ab8f-4b62-84e4-99f79cf085c2',
    UtaacDecision => '6f757605-ab8f-4b62-84e4-99f79cf085c2',
    DrugSafetyUpdate => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
    MedicalSafetyAlert => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
    RaibReport => "013872d8-8bbb-4e80-9b79-45c7c5cf9177",
    CountrysideStewardshipGrant => "d3ce4ba7-bc75-46b4-89d9-38cb3240376d",
    BusinessFinanceSupportScheme => "2bde479a-97f2-42b5-986a-287a623c2a1c",
    AsylumSupportDecision => '6f757605-ab8f-4b62-84e4-99f79cf085c2',
    ServiceStandardReport => "af07d5a5-df63-4ddc-9383-6a666845ebe9",
    InternationalDevelopmentFund => 'db994552-7644-404d-a770-a2fe659c661f',
  }

  document_types.each do |klass, primary_publishing_organisation_id|
    it "set primary publishing organisations for #{klass}" do
      document = klass.new
      document.content_id = 'a-content-id'
      allow(document).to receive(:schema_organisations).and_return('an-organisation-id')

      presenter = DocumentLinksPresenter.new(document)
      presented_data = presenter.to_json

      expect(presented_data[:content_id]).to eq('a-content-id')
      expect(presented_data[:links][:organisations]).to eq('an-organisation-id')
      expect(presented_data[:links][:primary_publishing_organisation]).to eq([primary_publishing_organisation_id])
    end
  end
end
