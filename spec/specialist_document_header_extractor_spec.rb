require "fast_spec_helper"

require "specialist_document_header_extractor"

describe SpecialistDocumentHeaderExtractor do
  subject(:header_extractor) {
    SpecialistDocumentHeaderExtractor.new(parser, doc)
  }

  let(:doc)     { double(:doc, body: doc_body, attributes: doc_attributes) }
  let(:parser)  { double(:parser, call: header_metadata) }

  let(:doc_body)          { double(:doc_body) }
  let(:doc_attributes)    { { body: doc_body } }
  let(:header_metadata)   { [header_metadatum] }
  let(:header_metadatum)  { double(:header_metadatum, headers: [], to_h: serialized_metadata) }
  let(:serialized_metadata) { double(:serialized_metadata) }

  it "is a true decorator" do
    expect(doc).to receive(:arbitrary_message)
    header_extractor.arbitrary_message
  end

  describe "#headers" do
    it "parses the document body with the govspeak parser" do
      header_extractor.headers

      expect(parser).to have_received(:call).with(doc_body)
    end

    it "returns header metadata from Govspeak" do
      expect(header_extractor.headers).to eq(header_metadata)
    end
  end

  describe "#serialized_headers" do
    it "returns the serialized headers" do
      expect(header_extractor.serialized_headers).to eq([serialized_metadata])
    end
  end

  describe "#attributes" do
    it "returns the document attributes with header metadata added" do
      expect(header_extractor.attributes).to include(doc_attributes)
      expect(header_extractor.attributes).to include(headers: [serialized_metadata])
    end
  end
end
