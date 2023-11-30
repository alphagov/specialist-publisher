require "spec_helper"

RSpec.describe DocumentLinksPresenter do
  document_types = {
    EmploymentTribunalDecision => "6f757605-ab8f-4b62-84e4-99f79cf085c2",
    AaibReport => "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4",
    CmaCase => "957eb4ec-089b-4f71-ba2a-dc69ac8919ea",
    EmploymentAppealTribunalDecision => "6f757605-ab8f-4b62-84e4-99f79cf085c2",
    MaibReport => "9c66b9a3-1e6a-48e8-974d-2a5635f84679",
    EsiFund => "2e7868a8-38f5-4ff6-b62f-9a15d1c22d28",
    TaxTribunalDecision => "6f757605-ab8f-4b62-84e4-99f79cf085c2",
    UtaacDecision => "6f757605-ab8f-4b62-84e4-99f79cf085c2",
    DrugSafetyUpdate => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
    MedicalSafetyAlert => "240f72bd-9a4d-4f39-94d9-77235cadde8e",
    ProductSafetyAlertReportRecall => "a0ee18e7-9e1e-4ba1-aed5-f3f287dce752",
    ProtectedFoodDrinkName => "de4e9dc6-cca4-43af-a594-682023b84d6c",
    RaibReport => "013872d8-8bbb-4e80-9b79-45c7c5cf9177",
    ResearchForDevelopmentOutput => "f9fcf3fe-2751-4dca-97ca-becaeceb4b26",
    CountrysideStewardshipGrant => "e8fae147-6232-4163-a3f1-1c15b755a8a4",
    BusinessFinanceSupportScheme => "2bde479a-97f2-42b5-986a-287a623c2a1c",
    AsylumSupportDecision => "6f757605-ab8f-4b62-84e4-99f79cf085c2",
    ServiceStandardReport => "2fb482e7-3c4d-496f-887d-f8a55a15e89a",
    InternationalDevelopmentFund => "f9fcf3fe-2751-4dca-97ca-becaeceb4b26",
  }

  document_types.each do |klass, primary_publishing_organisation_id|
    it "set primary publishing organisations for #{klass}" do
      document = klass.new
      document.content_id = "a-content-id"
      allow(document).to receive(:organisations).and_return(%w[an-organisation-id])

      presenter = DocumentLinksPresenter.new(document)
      presented_data = presenter.to_json

      expect(presented_data[:content_id]).to eq("a-content-id")
      expect(presented_data[:links][:organisations]).to eq(["an-organisation-id", primary_publishing_organisation_id])
      expect(presented_data[:links][:primary_publishing_organisation]).to eq([primary_publishing_organisation_id])
    end
  end

  it "expects the brexit taxon to be returned if the document type is Statutory Instrument" do
    document = StatutoryInstrument.new

    links_presenter = DocumentLinksPresenter.new(document)
    presented_data = links_presenter.to_json

    expect(presented_data[:links][:taxons]).to eq([Document::BREXIT_TAXON_ID])
  end
end
