require "formatters/abstract_artefact_formatter"

class CmaCaseArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "cma_case"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["competition-and-markets-authority"]
  end
end
