require "manual_artefact_formatter"

class ManualChangeNotesArtefactFormatter < ManualArtefactFormatter
  def resource_id
    [super, "updates"].join("/")
  end

  def slug
    [super, "updates"].join("/")
  end

  def kind
    "manual-change-history"
  end
end
