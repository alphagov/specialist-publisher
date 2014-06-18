require "manual_artefact_formatter"

class ManualChangeNotesArtefactFormatter < ManualArtefactFormatter
  def slug
    [super, "updates"].join("/")
  end

  def kind
    "manual-change-history"
  end
end
