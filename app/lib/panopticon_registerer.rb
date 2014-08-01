require "gds_api/panopticon"

class PanopticonRegisterer
  def initialize(dependencies)
    @mappings = dependencies.fetch(:mappings)
    @artefact = dependencies.fetch(:artefact)
    @api = dependencies.fetch(:api)
    @error_logger = dependencies.fetch(:error_logger)
  end

  def call
    if mapping
      notify_of_update
    else
      register_new_artefact
    end

    nil
  end

private
  attr_reader :mappings, :artefact, :api, :error_logger

  def register_new_artefact
    api
      .create_artefact!(artefact_attributes)
      .on_success(&method(:save_new_mapping))
      .on_error(&method(:log_error))
  end

  def notify_of_update
    api
      .put_artefact!(mapping.panopticon_id, artefact_attributes)
      .on_success(&method(:update_mapping_slug))
      .on_error(&method(:log_error))
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

  def log_error(error, *_api_args)
    error_logger.call(error)
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
end
