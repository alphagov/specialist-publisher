class FakePanopticon
  def create_artefact!(attributes = {})
    artefact = Artefact.new(attributes)

    if artefact.valid?
      artefact.save!
      return {'id' => artefact.id}
    else
      raise GdsApi::HTTPErrorResponse.new(422, 'errors' => artefact.errors.messages)
    end
  end
end

def stub_out_panopticon
  GdsApi::Panopticon.stub('new' => FakePanopticon.new)
end
