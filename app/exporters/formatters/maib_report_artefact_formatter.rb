require "formatters/abstract_artefact_formatter"

class MaibReportArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "maib_report"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["marine-accident-investigation-branch"]
  end
end
