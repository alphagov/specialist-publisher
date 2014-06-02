require "abstract_artefact_formatter"

class ManualDocumentArtefactFormatter < AbstractArtefactFormatter

  def state
    state_mapping.fetch(entity.publication_state)
  end

  def kind
    "manual-section"
  end

  def rendering_app
    "manuals-frontend"
  end

  private

  attr_reader :document
end
