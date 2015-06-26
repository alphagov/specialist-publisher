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

  describe "#reorder_documents" do
    let(:documents) {
      [
        alpha_document,
        beta_document,
        gamma_document,
      ]
    }

    let(:alpha_document) { double(:document, id: "alpha") }
    let(:beta_document) { double(:document, id: "beta") }
    let(:gamma_document) { double(:document, id: "gamma") }

    let(:document_order) { %w(gamma alpha beta) }

    it "reorders the documents to match the given order" do
      manual_with_documents.reorder_documents(%w(
        gamma
        alpha
        beta
      ))

      expect(manual_with_documents.documents.to_a).to eq([
        gamma_document,
        alpha_document,
        beta_document,
      ])
    end

    it "raises an error if document_order doesn't contain all IDs" do
      expect {
        manual_with_documents.reorder_documents(%w(
          alpha
          beta
        ))
      }.to raise_error(ArgumentError)
    end

    it "raises an error if document_order contains non-existent IDs" do
      expect {
        manual_with_documents.reorder_documents(%w(
          alpha
          beta
          gamma
          delta
        ))
      }.to raise_error(ArgumentError)
    end

    it "raises an error if document_order contains duplicate IDs" do
      expect {
        manual_with_documents.reorder_documents(%w(
          alpha
          beta
          gamma
          beta
        ))
      }.to raise_error(ArgumentError)
    end
  end

  describe "#remove_document" do
    subject(:manual_with_documents) {
      ManualWithDocuments.new(
        document_builder,
        manual,
        documents: documents,
        removed_documents: removed_documents,
      )
    }

    let(:documents) {
      [
        document_a,
        document_b,
      ]
    }
    let(:document_a) { double(:document, id: "a") }
    let(:document_b) { double(:document, id: "b") }

    let(:removed_documents) { [document_c] }
    let(:document_c) { double(:document, id: "c") }

    it "removes the document from #documents" do
      manual_with_documents.remove_document(document_a.id)

      expect(manual_with_documents.documents.to_a).to eq([document_b])
    end

    it "adds the document to #removed_documents" do
      manual_with_documents.remove_document(document_a.id)

      expect(manual_with_documents.removed_documents.to_a).to eq(
        [
          document_c,
          document_a,
        ]
      )
    end
  end
end
