require "formatters/abstract_specialist_document_indexable_formatter"

class EsiFundIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter

  def type
    "european_structural_investment_fund"
  end

private
  def extra_attributes
    {
      fund_state: entity.fund_state,
      fund_type: entity.fund_type,
      location: entity.location,
      funding_source: entity.funding_source,
      closing_date: entity.closing_date
    }
  end

  def organisation_slugs
    []
  end
end
