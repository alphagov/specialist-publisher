require 'spec_helper'
require 'finder_api'

describe FinderAPI do
  let(:http_client) { double(:http_client, post: nil) }
  let(:plek) { double(:plek) }
  let(:api_client) { FinderAPI.new(http_client, plek) }
  let(:document) { double(:document, finder_slug: 'cma-cases', to_json: "{some: 'json'}") }

  before do
    allow(plek).to receive(:find)
                   .with('finder-api')
                   .and_return("http://finder-api.example.com")
  end

  describe '#notify_of_publication(finder_slug, document)' do
    it 'posts to the Finder API with the document as JSON data' do
      expect(http_client).to receive(:new)
                             .with(url: "http://finder-api.example.com")
                             .and_return(http_client)

      api_client.notify_of_publication('cma-cases', document)

      expect(http_client).to have_received(:post).with(
        '/finders/cma-cases',
        "{some: 'json'}"
      )
    end
  end
end
