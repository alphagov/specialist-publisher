require "spec_helper"

RSpec.describe DocumentPresenter do
  let(:specialist_document) { CmaCase.from_publishing_api(payload) }
  let(:document_presenter) { DocumentPresenter.new(specialist_document) }
  let(:presented_data) { document_presenter.to_json }

  before do
    Timecop.freeze(Time.zone.parse("2015-12-03T16:59:13+00:00"))
  end

  after do
    Timecop.return
  end

  describe "#to_json without attachments" do
    let(:payload) do
      FactoryBot.create(:cma_case).tap { |p| p["details"].delete("attachments") }
    end

    it "is valid against the content schemas" do
      expect(presented_data[:schema_name]).to eq("specialist_document")
      expect(presented_data).to be_valid_against_publisher_schema("specialist_document")
    end

    it "does not contain attachments key" do
      expect(presented_data[:attachments]).to be(nil)
    end

    it "returns a specialist document content item" do
      expected = write_payload(payload)
      expect(presented_data).to eq(expected.to_h.deep_symbolize_keys)
    end
  end

  describe "#to_json with attachments" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        details: {
          attachments: [
            {
              "attachment_type" => "file",
              "id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
              "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
              "content_type" => "application/jpeg",
              "title" => "asylum report image title",
              "created_at" => "2015-12-03T16:59:13+00:00",
              "updated_at" => "2015-12-03T16:59:13+00:00",
            },
            {
              "attachment_type" => "file",
              "id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
              "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
              "content_type" => "application/pdf",
              "title" => "asylum report pdf title",
              "created_at" => "2015-12-03T16:59:13+00:00",
              "updated_at" => "2015-12-03T16:59:13+00:00",
            },
          ],
        },
      )
    end

    it "is valid against the content schemas" do
      expect(presented_data[:schema_name]).to eq("specialist_document")
      expect(presented_data).to be_valid_against_publisher_schema("specialist_document")
    end

    it "contains the attachments" do
      expected_attachments = payload["details"]["attachments"].map(&:symbolize_keys)
      expect(presented_data[:details][:attachments]).to eq(expected_attachments)
    end

    it "sends the temporary_update_type as a boolean so that it validates against the schema" do
      expect(presented_data[:details][:temporary_update_type]).to eq(false)
    end
  end

  describe "#to_json with headers" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        details: {
          body: [
            {
              "content_type" => "text/govspeak",
              "content" => "## heading",
            },
          ],
        },
      )
    end

    it "is valid against the content schemas" do
      expect(presented_data).to be_valid_against_publisher_schema("specialist_document")
    end

    it "adds the header to the payload" do
      expected_headers_payload = [{ text: "heading", level: 2, id: "heading" }]

      expect(presented_data[:details][:headers]).to eq(expected_headers_payload)
    end
  end

  describe "#to_json with nested headers" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        details: {
          body: [
            {
              "content_type" => "text/govspeak",
              "content" => "## heading2\r\n\r\n### heading3\r\n\r\n#### heading4\r\n\r\n## anotherheading2",
            },
          ],
        },
      )
    end

    it "is valid against the content schemas" do
      expect(presented_data).to be_valid_against_publisher_schema("specialist_document")
    end

    it "adds the nested header to the payload" do
      expected_headers_payload = [
        { text: "heading2",
          level: 2,
          id: "heading2",
          headers: [
            { text: "heading3",
              level: 3,
              id: "heading3",
              headers: [
                { text: "heading4", level: 4, id: "heading4" },
              ] },
          ] },
        { text: "anotherheading2", level: 2, id: "anotherheading2" },
      ]

      expect(presented_data[:details][:headers]).to eq(expected_headers_payload)
    end
  end

  describe "#to_json without headers" do
    let(:payload) do
      FactoryBot.create(:cma_case).tap { |p| p["details"].delete("headers") }
    end

    it "is valid against the content schemas" do
      expect(presented_data).to be_valid_against_publisher_schema("specialist_document")
    end

    it "does not add a headers section to the payload" do
      expect(presented_data[:details]).to_not include(:headers)
    end
  end

  describe "#to_json with format_specific_fields" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        details: {
          metadata: {
            case_state: "open",
            case_type: "ca98-and-civil-cartels",
            outcome_type: "",
            bulk_published: true,
          },
        },
      )
    end

    let(:metadata) { presented_data[:details][:metadata] }

    it "returns the format specific fields in the details.metadata" do
      expect(metadata).to include(
        case_state: "open",
        case_type: "ca98-and-civil-cartels",
      )
    end

    it "does not return fields that are blank" do
      expect(metadata).not_to include(
        :outcome_type,
      )
    end

    it "does not return the document_type in details.metadata" do
      expect(metadata).not_to include(
        :document_type,
      )
    end

    it "returns bulk_published in details metadata" do
      expect(metadata).to include(
        bulk_published: true,
      )
    end
  end

  describe "#to_json with custom downstream_document_type defined in schema" do
    let(:payload) { FactoryBot.create(:cma_case) }

    context "when the document schema specifies a `downstream_document_type`" do
      before do
        allow_any_instance_of(FinderSchema).to receive(:downstream_document_type).and_return("custom_document_type")
      end

      it "returns the schema document type rather than than the model name based document type" do
        expect(presented_data[:document_type]).to eq("custom_document_type")
      end
    end

    context "when the document schema does not specify a `downstream_document_type`" do
      before do
        allow_any_instance_of(FinderSchema).to receive(:downstream_document_type).and_return(nil)
      end

      it "returns the model name based document type" do
        expect(presented_data[:document_type]).to eq(specialist_document.document_type)
      end
    end
  end
end
