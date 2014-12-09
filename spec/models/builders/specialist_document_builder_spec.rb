require "spec_helper"

describe SpecialistDocumentBuilder do
  subject(:builder) {
    SpecialistDocumentBuilder.new(document_type, document_factory)
  }

  let(:document_type)     { "dummy_document" }
  let(:document_factory)  { double(:document_factory, call: document) }
  let(:document)          { double(:document, update: nil) }

  describe "#call" do
    it "creates a new document" do
      expect(builder.call({})).to eq(document)
      expect(document).to have_received(:update).with({
        document_type: document_type,
        change_note: "First published.",
      })
    end
  end
end
