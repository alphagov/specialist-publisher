require "specialist_document_edition"

SpecialistDocumentEdition.class_eval do
  # Reopening this from the Content Models

  field :document_type, type: String
end
