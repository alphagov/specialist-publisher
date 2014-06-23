require "abstract_artefact_formatter"

class AaibReportArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "specialist-document"
  end

  def rendering_app
    "specialist-frontend"
  end

  def organisation_slugs
    ["air-accidents-investigation-branch"]
  end
end
