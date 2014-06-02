require "fast_spec_helper"

require "manual_with_documents"

describe ManualWithDocuments do

  subject(:manual_with_documents) {
    ManualWithDocuments.new(document_builder, manual, documents: documents)
  }

  let(:manual) { double(:manual, publish: nil) }
  let(:document_builder) { double(:document_builder) }
  let(:documents) { [document] }
  let(:document) { double(:document, publish!: nil) }

  let(:id) { double(:id) }
  let(:updated_at) { double(:updated_at) }
  let(:title) { double(:title) }
  let(:summary) { double(:summary) }
  let(:organisation_slug) { double(:organisation_slug) }
  let(:state) { double(:state) }

  it "rasies an error without an ID" do
    expect {
      Manual.new({})
    }.to raise_error
  end

  describe "#publish" do
    it "notifies the underlying manual" do
      manual_with_documents.publish

      expect(manual).to have_received(:publish)
    end

    context "when the manual publish succeeds" do
      before do
        allow(manual).to receive(:publish).and_yield
      end

      it "passes a block which publishes" do
        manual_with_documents.publish

        expect(document).to have_received(:publish!)
      end
    end

    context "when the manual publish does not succeed" do
      it "does not publish the documents" do
        manual_with_documents.publish

        expect(document).not_to have_received(:publish!)
      end
    end
  end
end
