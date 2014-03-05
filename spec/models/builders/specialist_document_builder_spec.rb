require "spec_helper"

describe SpecialistDocumentBuilder do
  subject(:builder) {
    SpecialistDocumentBuilder.new(
      document_factory,
      id_generator,
    )
  }

  let(:document_factory)  { double(:document_factory, call: document) }
  let(:id_generator)      { double(:id_generator, call: document_id) }

  let(:document_id)       { double(:document_id) }
  let(:attrs)             { double(:attrs) }
  let(:document)          { double(:document, update: nil) }

  describe "#call" do
    it "generates an id" do
      builder.call(attrs)

      expect(id_generator).to have_received(:call)
    end

    it "creates a new document" do
      builder.call(attrs)

      expect(document_factory).to have_received(:call)
        .with(document_id, [])
    end

    it "updates the document with the attributes" do
      builder.call(attrs)

      expect(document).to have_received(:update).with(attrs)
    end
  end
end
