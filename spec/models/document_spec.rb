require 'spec_helper'

describe Document do
  class MyDocumentType < Document
    def self.title
      "My Document Type"
    end

    def self.publishing_api_document_type
      "my_document_type"
    end
  end

  it "has a document_type for building URLs" do
    expect(MyDocumentType.document_type).to eq("my-document-types")
  end

  it "has a format_name for fetching params of the format" do
    expect(MyDocumentType.format_name).to eq("my_document_type")
  end

  it "requests content items with descending update_at order" do
    publishing_api = double(:publishing_api)
    allow(Services).to receive(:publishing_api).and_return(publishing_api)

    expect(publishing_api).to receive(:get_content_items)
      .with(hash_including(order: "-updated_at"))

    MyDocumentType.all(1, 20)
  end
end
