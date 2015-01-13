require "formatters/abstract_artefact_formatter"

class RaibReportArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "raib_report"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["rail-accident-investigation-branch"]
  end
end
