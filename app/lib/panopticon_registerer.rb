require "gds_api/panopticon"

class PanopticonRegisterer
  def initialize(dependencies)
    @mappings = dependencies.fetch(:mappings)
    @artefact = dependencies.fetch(:artefact)
  end

  def call
    if mapping
      notify_of_update
    else
      register_new_artefact
    end
  end

private
  attr_reader :mappings, :artefact

  def register_new_artefact
    response = api.create_artefact!(artefact_attributes)

    save_new_mapping(response)
  end

  def notify_of_update
    response = api.put_artefact!(mapping.panopticon_id, artefact_attributes)

    update_mapping_slug(response)
  end

  def save_new_mapping(response)
    mappings.create!(
      resource_id: artefact.resource_id,
      resource_type: artefact.kind,
      slug: artefact.slug,
      panopticon_id: response["id"],
    )
  end

  def update_mapping_slug(response)
    mapping.update_attribute(:slug, artefact.slug)
  end

  def artefact_attributes
    artefact.attributes.merge(
      owning_app: owning_app,
    )
  end

  def mapping
    @mapping ||= mappings.where(resource_id: artefact.resource_id).last
  end

  def owning_app
    "specialist-publisher"
  end

  def api
    @api ||= GdsApi::Panopticon.new(
      Plek.current.find("panopticon"),
      PANOPTICON_API_CREDENTIALS
    )
  end
end
