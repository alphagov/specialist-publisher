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
      document,
      specialist_document_renderer: specialist_document_renderer,
      publication_logs: publication_logs
    )
  }

  let(:publication_logs) { class_double("PublicationLog", change_notes_for: [publication_log]) }

  let(:publication_log) {
    instance_double("PublicationLog",
      slug: document.slug,
      title: document.title,
      version_number: document.version_number,
      change_note: "My change note",
      published_at: 1.day.ago
    )
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

    it "should include the document change history" do
      expect(publication_logs).to receive(:change_notes_for).with(document.slug)
      expect(presented['details']['change_history'].size).to eq(1)
    end

  end
end
