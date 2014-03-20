require 'spec_helper'
require 'finder_api_notifier'

describe FinderAPINotifier do
  describe '#call(document)' do
    let(:document) { double(:specialist_document,
                            finder_slug: 'finder-999',
                            attributes: {title: 'A title'}
    )}
    let(:api_client) { double(:finder_api, notify_of_publication: nil) }
    let(:notifier) { FinderAPINotifier.new(api_client) }

    it "sends all the document's attributes to the Finder API" do
      notifier.call(document)
      expect(api_client).to have_received(:notify_of_publication).with(
        'finder-999',
        {title: 'A title'}
      )
    end
  end
end
