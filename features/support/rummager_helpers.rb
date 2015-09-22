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
    # Stub both rummager methods so RSpec can spy on them
    allow(fake_rummager).to receive(:add_document).and_call_original
    allow(fake_rummager).to receive(:delete_document).and_call_original

    allow(GdsApi::Rummager).to receive(:new)
      .and_return(fake_rummager)
  end

  def fake_rummager
    # memoizing does not work here for some reason
    FakeRummager.instance
  end

  def mock_rummager_http_server_error
    allow(fake_rummager).to receive(:add_document).and_raise(GdsApi::HTTPServerError.new(500))
    allow(fake_rummager).to receive(:delete_document).and_raise(GdsApi::HTTPServerError.new(500))
  end

  def mock_rummager_http_client_error
    allow(fake_rummager).to receive(:add_document).and_raise(GdsApi::HTTPClientError.new(400))
    allow(fake_rummager).to receive(:delete_document).and_raise(GdsApi::HTTPClientError.new(400))
  end
end
RSpec.configuration.include RummagerHelpers, type: :feature
