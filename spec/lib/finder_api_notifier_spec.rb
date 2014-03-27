require 'spec_helper'
require 'finder_api_notifier'

describe FinderAPINotifier do
  describe '#call(document)' do
    let(:document) { double(:specialist_document,
                            attributes: document_attributes,
                            slug: document_slug,
    )}
    let(:api_client) { double(:finder_api, notify_of_publication: nil) }
    let(:notifier) { FinderAPINotifier.new(api_client) }
    let(:document_slug) { "cma-cases/a-cma-case-document" }
    let(:document_attributes) { double(:document_attributes) }

    it "sends all the document's attributes to the Finder API" do
      notifier.call(document)

      expect(api_client).to have_received(:notify_of_publication).with(
        document_slug,
        document_attributes
      )
    end
  end
end
