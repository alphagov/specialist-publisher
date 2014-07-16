require "validators/date_validator"
require "validators/core_document_validator"

class AaibReportValidator < CoreDocumentValidator
  validates :date_of_occurrence, presence: true, date: true
end
