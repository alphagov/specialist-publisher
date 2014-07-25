require "abstract_artefact_formatter"

class InternationalDevelopmentFundArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "international_development_fund"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["department-for-international-development"]
  end
end
