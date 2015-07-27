require "fast_spec_helper"

require "specialist_document_publishing_api_exporter"

describe SpecialistDocumentPublishingAPIExporter do

  let(:publishing_api) {
    double(:publishing_api)
  }

  let(:document_path) { "/cma-cases/foo" }

  let(:document_data) {
    {
      content_id: "4bf43033-6c7a-4911-bc03-867945d9b937",
      format: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      title: "This is a title",
      description: "This is a description",
      update_type: "major",
      locale: "en",
      public_updated_at: Time.now,
      details: {}
    }
  }

  let(:document) {
    double(
      "FormattedSpecialistDocument",
      call: document_data,
      base_path: document_path
    )
  }

  subject {
    described_class.new(
      publishing_api,
      document,
      draft
    )
  }

  context "a published item" do
    let(:draft) { false }

    it "exports to the publishing api" do
      expect(publishing_api).to receive(:put_content_item).with(document_path, document_data)
      subject.call
    end
  end

  context "a draft item" do
    let(:draft) { true }

    it "exports to the publishing api" do
      expect(publishing_api).to receive(:put_draft_content_item).with(document_path, document_data)
      subject.call
    end
  end
end
