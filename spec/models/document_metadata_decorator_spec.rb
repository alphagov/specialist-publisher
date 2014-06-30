require "fast_spec_helper"
require "document_metadata_decorator"

RSpec.describe DocumentMetadataDecorator do

  subject(:document_with_metadata) {
    extra_attributes_keys = extra_attributes.keys

    Class.new(DocumentMetadataDecorator) {
      set_extra_field_names(extra_attributes_keys)
    }.new(document)
  }

  let(:document) {
    double(
      :document,
      attributes: document_attributes,
      update: nil,
    )
  }

  let(:document_attributes) {
    basic_attributes.merge(
      extra_fields: extra_attributes
    )
  }

  let(:attributes_with_extras) {
    basic_attributes.merge(extra_attributes)
  }

  let(:basic_attributes) {
    {
      foo: "bar",
      baz: "qux",
    }
  }

  let(:extra_attributes) {
    {
      extra_foo: extra_foo,
    }
  }

  let(:extra_foo) { double(:extra_foo) }

  it "is a true decorator" do
    expect(document).to receive(:arbitrary_message)
    document_with_metadata.arbitrary_message
  end

  describe "#update" do
    it "updates the document, separating out extra attributes" do
      document_with_metadata.update(attributes_with_extras)

      expect(document).to have_received(:update).with(document_attributes)
    end
  end

  describe "#attributes" do
    it "returns attributes from document, including extra_fields" do
      expect(document_with_metadata.attributes).to eq(attributes_with_extras)
    end
  end
end
