require "formatters/abstract_specialist_document_indexable_formatter"

class InternationalDevelopmentFundIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "international_development_fund"
  end

private
  def extra_attributes
    {
      fund_state: entity.fund_state,
      location: entity.location,
      development_sector: entity.development_sector,
      eligible_entities: entity.eligible_entities,
      value_of_funding: entity.value_of_funding,
    }
  end

  def organisation_slugs
    ["department-for-international-development"]
  end
end
