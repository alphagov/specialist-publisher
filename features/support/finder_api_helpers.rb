require "singleton"
require "finder_api"

module FinderAPIHelpers
  class FakeFinderAPI
    include Singleton

    def notify_of_publication(slug, document_attributes)
    end

    def notify_of_withdrawal(slug)
    end
  end

  def stub_finder_api
    # Allow RSpec to spy on the FinderAPI adapter
    allow(fake_finder_api).to receive(:notify_of_publication).and_call_original
    allow(fake_finder_api).to receive(:notify_of_withdrawal).and_call_original

    allow(FinderAPI).to receive(:new)
      .and_return(fake_finder_api)
  end

  def reset_finder_api_stubs_and_messages
    RSpec::Mocks.space.proxy_for(finder_api).reset
    stub_finder_api
  end

  def fake_finder_api
    # memoizing does not work here for some reason
    FakeFinderAPI.instance
  end
end
