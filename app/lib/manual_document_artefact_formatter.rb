require "abstract_artefact_formatter"

class ManualDocumentArtefactFormatter < AbstractArtefactFormatter
  def initialize(entity, manual)
    @entity = entity
    @manual = manual
  end

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "manual-section"
  end

  def rendering_app
    "manuals-frontend"
  end

  def organisation_slugs
    [manual.organisation_slug]
  end

private
  attr_reader :manual
end
