require "abstract_indexable_formatter"

class CmaCaseIndexableFormatter < AbstractIndexableFormatter
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
    }
  end

  def organisation_slugs
    ["competition-and-markets-authority"]
  end
end
