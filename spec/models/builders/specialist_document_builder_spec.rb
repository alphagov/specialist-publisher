require "spec_helper"

describe SpecialistDocumentBuilder do
  subject(:builder) {
    SpecialistDocumentBuilder.new(document_factory)
  }

  let(:document_factory)  { double(:document_factory, call: document) }
  let(:document_id)       { double(:document_id) }
  let(:attrs)             { double(:attrs) }
  let(:document)          { double(:document, update: nil) }

  describe "#call" do
    it "creates a new document" do
      expect(builder.call(attrs)).to eq(document)
      expect(document).to have_received(:update).with(attrs)
    end
  end
end
