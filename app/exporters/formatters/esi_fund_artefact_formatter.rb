require "formatters/abstract_artefact_formatter"

class EsiFundArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "european_structural_investment_fund"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    []
  end
end
