class FakePanopticon
  def put_artefact!(id, attributes = {})
    artefact = Artefact.find(id)
    attributes.each do |key, value|
      artefact.send("#{key}=", value)
    end

    if artefact.valid?
      artefact.save!
      return nil
    else
      raise GdsApi::HTTPErrorResponse.new(422, 'errors' => artefact.errors.messages)
    end
  end

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
