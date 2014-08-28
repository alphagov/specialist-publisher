require "abstract_artefact_formatter"

class MedicalSafetyAlertArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "medical_safety_alert"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["medicines-and-healthcare-products-regulatory-agency"]
  end
end
