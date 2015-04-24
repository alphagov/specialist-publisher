require "formatters/abstract_artefact_formatter"

class VehicleRecallsAndFaultsAlertArtefactFormatter < AbstractArtefactFormatter
  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "vehicle_recalls_and_faults_alert"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["driver-and-vehicle-standards-agency"]
  end
end
