require "singleton"

module PanopticonHelpers

  class FakePanopticon
    def initialize
      @artefacts = {}
    end

    def artefact_for_slug(slug)
      artefacts.fetch(slug) { slug_does_not_exist!(slug) }
    end

    def put_artefact!(slug, attributes)
      artefact = artefacts.fetch(slug) { slug_does_not_exist!(slug) }
      artefacts.store(slug, artefact.merge(attributes))
    end

    def create_artefact!(attributes = {})
      artefacts.store(attributes.fetch(:slug), attributes)
    end

    private
    attr_reader :artefacts

    def slug_does_not_exist!(slug)
      raise GdsApi::HTTPNotFound.new(404, "url: #{slug}")
    end
  end

  def fake_panopticon
    @fake_panopticon ||= FakePanopticon.new
  end

  def reset_panopticon_stubs_and_messages
    RSpec::Mocks.space.proxy_for(fake_panopticon).reset
    stub_panopticon
  end

  def stub_panopticon
    # Stub both panopticon methods so RSpec can spy on them
    allow(fake_panopticon).to receive(:put_artefact!).and_call_original
    allow(fake_panopticon).to receive(:create_artefact!).and_call_original

    allow(GdsApi::Panopticon).to receive(:new)
      .and_return(fake_panopticon)
  end

  def mock_panopticon_http_error_once(error_code)
    allow(fake_panopticon).to receive(:put_artefact!).and_raise(GdsApi::HTTPErrorResponse.new(error_code)).once
    allow(fake_panopticon).to receive(:create_artefact!).and_raise(GdsApi::HTTPErrorResponse.new(error_code)).once
  end

  def mock_panopticon_timeout
    allow(fake_panopticon).to receive(:put_artefact!).and_raise(GdsApi::TimedOutException)
    allow(fake_panopticon).to receive(:create_artefact!).and_raise(GdsApi::TimedOutException)
  end
end
