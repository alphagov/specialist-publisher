class PanopticonRegisterer
  def initialize(api, mappings, document)
    @api = api
    @mappings = mappings
    @document = document
  end

  def call
    raise "Publication failed" unless mapping

    api.put_artefact!(mapping.id, artefact_attributes_for(document))
  end

  private

  attr_reader :api, :mappings, :document

  def mapping
    @mapping ||= mappings.where(document_id: document.id).last
  end

  def notify_of_publish(id, document)
    api.put_artefact!(id, artefact_attributes_for(document, 'live'))
  end

  def artefact_state
    "live"
  end

  def artefact_attributes_for(document)
    {
      name: document.title,
      slug: document.slug,
      kind: 'specialist-document',
      owning_app: 'specialist-publisher',
      rendering_app: 'specialist-frontend',
      paths: ["/#{document.slug}"],
      state: artefact_state,
    }
  end
end
