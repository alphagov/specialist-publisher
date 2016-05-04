require 'spec_helper'

describe Document do
  class MyDocumentType < Document
    def self.title
      "My Document Type"
    end
  end

  it "has a document_type for building URLs" do
    expect(MyDocumentType.document_type).to eq("my-document-types")
  end

  it "has a format_name for fetching params of the format" do
    expect(MyDocumentType.format_name).to eq("my_document_type")
  end
end
