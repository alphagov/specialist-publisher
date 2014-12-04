require "formatters/abstract_artefact_formatter"

class DrugSafetyUpdateArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "drug_safety_update"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["medicines-and-healthcare-products-regulatory-agency"]
  end
end
