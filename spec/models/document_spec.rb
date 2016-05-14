require 'spec_helper'

RSpec.describe Document do
  class MyDocumentType < Document
    def self.title
      "My Document Type"
    end
  end

  it "has a document_type for building URLs" do
    expect(MyDocumentType.slug).to eq("my-document-types")
  end

  it "has a document_type for fetching params of the format" do
    expect(MyDocumentType.document_type).to eq("my_document_type")
  end

  describe ".all" do
    it "makes a request to the publishing api with the correct params" do
      publishing_api = double(:publishing_api)
      allow(Services).to receive(:publishing_api).and_return(publishing_api)

      expect(publishing_api).to receive(:get_content_items)
        .with(
          document_type: "my_document_type",
          fields: [
            :base_path,
            :content_id,
            :updated_at,
            :title,
            :publication_state,
          ],
          page: 1,
          per_page: 20,
          order: "-updated_at",
          q: "foo",
        )

      MyDocumentType.all(1, 20, q: "foo")
    end
  end
end
