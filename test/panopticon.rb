class FakePanopticon
  def put_artefact!(id, attributes = {})
    nil
  end

  def create_artefact!(attributes = {})
    {"id" => "random-panopticon-id-#{SecureRandom.hex}"}
  end
end

def stub_out_panopticon
  GdsApi::Panopticon.stub('new' => FakePanopticon.new)
end
