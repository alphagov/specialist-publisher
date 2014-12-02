require "formatters/abstract_specialist_document_indexable_formatter"

class CmaCaseIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "cma_case"
  end

private
  def extra_attributes
    {
      case_type: entity.case_type,
      case_state: entity.case_state,
      market_sector: entity.market_sector,
      outcome_type: entity.outcome_type,
      opened_date: entity.opened_date,
      closed_date: entity.closed_date,
    }
  end

  def organisation_slugs
    ["competition-and-markets-authority"]
  end
end
