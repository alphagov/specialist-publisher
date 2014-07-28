require "validators/date_validator"
require "validators/specialist_document_validator"

class CmaCaseValidator < SpecialistDocumentValidator
  validates :opened_date, presence: true, date: true
  validates :market_sector, presence: true
  validates :case_type, presence: true
  validates :case_state, presence: true
  validates :closed_date, allow_blank: true, date: true
end
