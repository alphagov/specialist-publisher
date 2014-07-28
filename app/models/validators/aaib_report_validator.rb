require "validators/date_validator"
require "validators/specialist_document_validator"

class AaibReportValidator < SpecialistDocumentValidator
  validates :date_of_occurrence, presence: true, date: true
end
