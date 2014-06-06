require "spec_helper"
require "finder_api"

describe FinderAPI do
  let(:http_client) { double(:http_client, put: nil, delete: nil) }
  let(:plek) { double(:plek) }
  let(:api_client) { FinderAPI.new(http_client, plek) }
  let(:document) { double(:document, to_json: "{some: 'json'}") }
  let(:document_slug) { "cma-cases/a-cma-case-document" }

  before do
    allow(plek).to receive(:find)
                   .with("finder-api")
                   .and_return("http://finder-api.example.com")

    allow(http_client).to receive(:new)
                           .with(url: "http://finder-api.example.com")
                           .and_return(http_client)
  end

  describe "#notify_of_publication(finder_type, document)" do
    it "puts to the Finder API with the document as JSON data" do
      api_client.notify_of_publication(document_slug, document)

      expect(http_client).to have_received(:put).with(
        "/finders/#{document_slug}",
        document: "{some: 'json'}"
      )
    end
  end

  describe "#notify_of_withdrawal" do
    let(:slug) { "some-slug" }
    let(:finder_url) { "/finders/#{slug}" }

    it "deletes from the documents Finder API URL" do
      api_client.notify_of_withdrawal(slug)

      expect(http_client).to have_received(:delete).with(finder_url)
    end
  end
end
