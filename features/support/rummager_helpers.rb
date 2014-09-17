require "singleton"

module RummagerHelpers

  class FakeRummager
    include Singleton

    def add_document(type, id, document)
    end

    def delete_document(type, id)
    end
  end

  def stub_rummager
    # Stub both panopticon methods so RSpec can spy on them
    allow(fake_rummager).to receive(:add_document).and_call_original
    allow(fake_rummager).to receive(:delete_document).and_call_original

    allow(GdsApi::Rummager).to receive(:new)
      .and_return(fake_rummager)
  end

  def reset_rummager_stubs_and_messages
    RSpec::Mocks.space.proxy_for(fake_rummager).reset
    stub_rummager
  end

  def fake_rummager
    # memoizing does not work here for some reason
    FakeRummager.instance
  end
end
