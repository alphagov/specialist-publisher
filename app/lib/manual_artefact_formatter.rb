require "abstract_artefact_formatter"

class ManualArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.state)
  end

  def kind
    "manual"
  end

  def rendering_app
    "manuals-frontend"
  end

  def organisation_slugs
    [entity.organisation_slug]
  end
end
