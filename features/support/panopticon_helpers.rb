require "singleton"

module PanopticonHelpers

  class FakePanopticon
    include Singleton

    def initialize
      @slug_id_map = {}
    end

    def put_artefact!(id, attributes = {})
      raise "No artifact with id #{id} exists" unless slug_id_map.has_value?(id)

      slug_id_map[attributes.fetch(:slug)] = id

      {"id" => id, "slug" => attributes.fetch(:slug)}
    end

    def create_artefact!(attributes = {})
      new_artefact_id = "test-panopticon-id-#{SecureRandom.hex}"
      slug_id_map[attributes.fetch(:slug)] = new_artefact_id

      {"id" => new_artefact_id, "slug" => attributes.fetch(:slug)}
    end

    def panopticon_id_for_slug(slug)
      slug_id_map.fetch(slug) { raise "No artefact with slug '#{slug}' was created" }
    end

    private
    attr_reader :slug_id_map
  end

  def fake_panopticon
    # memoizing does not work here for some reason
    FakePanopticon.instance
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

  def mock_panopticon_timeout
    allow(fake_panopticon).to receive(:put_artefact!).and_raise(GdsApi::TimedOutException)
    allow(fake_panopticon).to receive(:create_artefact!).and_raise(GdsApi::TimedOutException)
  end

  def panopticon_id_for_slug(slug)
    fake_panopticon.panopticon_id_for_slug(slug)
  end
end
