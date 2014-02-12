class MockPanopticon
  def create_artefact!(attributes = {})
    artefact = Artefact.create!(attributes)
    {'id' => artefact.id}
  end
end

def stub_out_panopticon
  GdsApi::Panopticon.stub('new' => MockPanopticon.new)
end
