class PanopticonRegisterer
  def initialize(api, mappings, document)
    @api = api
    @mappings = mappings
    @document = document
  end

  def call
    if mapping
      notify_of_update
    else
      register_new_document
    end
  end

  private

  attr_reader :api, :mappings, :document

  def register_new_document
    response = api.create_artefact!(artefact_attributes)

    save_new_mapping(response)
  end

  def notify_of_update
    api.put_artefact!(mapping.panopticon_id, artefact_attributes)
  end

  def mapping
    @mapping ||= mappings.where(document_id: document.id).last
  end

  def save_new_mapping(response)
    mappings.create!(
      document_id: document.id,
      panopticon_id: response["id"],
      slug: document.slug,
    )
  end

  def artefact_state
    document.published? ? "live" : "draft"
  end

  def artefact_attributes
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
