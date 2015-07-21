require "spec_helper"
require "formatters/specialist_document_publishing_api_formatter"
require "support/govuk_content_schema_helpers"
require "specialist_publisher_wiring"
require "specialist_document"


RSpec.describe SpecialistDocumentPublishingApiFormatter do
  let(:specialist_document_renderer) {
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  }
  let(:formatter) {
    described_class.new(
        document, specialist_document_renderer: specialist_document_renderer
    )
  }

  let(:document) {
    SpecialistDocument.new(nil, edition.id, [edition])
  }

  let(:document) {
    SpecialistDocument.new(nil, edition.document_id, [edition], nil)
  }

  let(:edition) {
    FactoryGirl.create(
      :specialist_document_edition,
      document_id: SecureRandom.uuid,
      document_type: "cma_case",
      updated_at: 2.days.ago,
      body: body,
      extra_fields: {
        case_type: "mergers",
        case_state: "open",
        market_sector: [
          "clothing-footwear-and-fashion"
        ],
        opened_date: "2015-07-10"
      },
    )
  }

  let(:body) { "" }

  subject(:presented) { formatter.call.as_json }

  context "a CMA Case document" do
    it "should generate a hash which is valid against the specialist_document schema" do
      expect(presented).to be_valid_against_schema("specialist_document")
    end

    it "should include the relevant metadata in the details hash" do
      fields = ["case_type", "case_state", "market_sector", "opened_date", "document_type"]
      expect(presented["details"]["metadata"].keys).to eq(fields)
    end
  end
end
