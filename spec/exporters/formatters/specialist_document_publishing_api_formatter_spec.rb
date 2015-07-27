require "spec_helper"
require "formatters/specialist_document_publishing_api_formatter"
require "support/govuk_content_schema_helpers"
require "specialist_publisher_wiring"
require "specialist_document"

RSpec.describe SpecialistDocumentPublishingAPIFormatter do
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
    AaibReport.new(
      SpecialistDocument.new(nil, edition.document_id, [edition], nil)
    )
  }

  let(:edition) {
    FactoryGirl.create(
      :specialist_document_edition,
      document_id: SecureRandom.uuid,
      document_type: "cma_case",
      updated_at: 2.days.ago,
      body: body,
      state: state,
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

  let(:state) { "published" }

  subject(:presented) { formatter.call.as_json }

  context "a CMA Case document" do
    it "should generate a hash which is valid against the specialist_document schema" do
      expect(presented).to be_valid_against_schema("specialist_document")
    end

    it "should include the relevant metadata in the details hash" do
      fields = %w(case_type case_state market_sector opened_date document_type)
      expect(presented["details"]["metadata"].keys).to eq(fields)
    end

    it "should include the document change history" do
      expect(publication_logs).to receive(:change_notes_for).with(document.slug)
      expect(presented["details"]["change_history"].size).to eq(1)
    end

    it "should not include an access_limited hash" do
      expect(presented).not_to include("access_limited")
    end

    context "with a body containing some govspeak" do
      let(:body) { "## Heading 2\n\nParagraph" }

      it { should be_valid_against_schema("specialist_document") }

      it "should convert the body from govspeak to html" do
        expect(presented["details"]["body"]).to eq(%{<h2 id="heading-2">Heading 2</h2>\n\n<p>Paragraph</p>\n})
      end
    end

    context "with a body containing a govspeak header" do
      let(:body) { "## Heading 2\n\nParagraph" }

      it { should be_valid_against_schema("specialist_document") }

      it "should extract headers" do
        expect(presented["details"]["headers"]).to eq([{"text" => "Heading 2", "level" => 2, "id" => "heading-2"}])
      end
    end

    context "with a body containing govspeak without headers" do
      let(:body) { "This is a paragraph" }

      it { should be_valid_against_schema("specialist_document") }

      it "should omit the headers attribute" do
        expect(presented["details"].keys).not_to include("headers")
      end
    end

    context "with a body containing multiple govspeak headers" do
      let(:body) {
        <<END_OF_GOVSPEAK
## Heading 2

### Heading 3a

### Heading 3b

### Heading 3c

END_OF_GOVSPEAK
      }

      it { should be_valid_against_schema("specialist_document") }

      it "should extract headers" do
        expect(presented["details"]["headers"]).to eq(
          [
            {
              "text" => "Heading 2",
              "level" => 2,
              "id" => "heading-2",
              "headers" => [
                {
                  "text" => "Heading 3a",
                  "level" => 3,
                  "id" => "heading-3a"
                },
                {
                  "text" => "Heading 3b",
                  "level" => 3,
                  "id" => "heading-3b"
                },
                {
                  "text" => "Heading 3c",
                  "level" => 3,
                  "id" => "heading-3c"
                }
              ]
            }
          ]
        )
      end
    end

    context "in draft state" do
      let(:state) { "draft" }

      let!(:cma_editor) { FactoryGirl.create(:cma_editor) }
      let!(:aaib_editor) { FactoryGirl.create(:aaib_editor) }
      let!(:gds_editor) { FactoryGirl.create(:gds_editor) }

      it "includes an access_limited hash" do
        expect(presented).to include("access_limited")
      end

      it "includes uids of departmental editors and GDS editors" do
        expect(presented["access_limited"]["users"]).to eq([cma_editor.uid, gds_editor.uid])
      end
    end
  end
end
