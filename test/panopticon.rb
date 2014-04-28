class FakePanopticon
  include Singleton

  def put_artefact!(id, attributes = {})
    nil
  end

  def create_artefact!(attributes = {})
    {"id" => "random-panopticon-id-#{SecureRandom.hex}"}
  end
end

def fake_panopticon
  # memoizing does not work here for some reason
  FakePanopticon.instance
end

def stub_out_panopticon
  # Stub both panopticon methods so RSpec can spy on them
  allow(fake_panopticon).to receive(:put_artefact!).and_call_original
  allow(fake_panopticon).to receive(:create_artefact!).and_call_original

  allow(GdsApi::Panopticon).to receive(:new)
    .and_return(fake_panopticon)
end
