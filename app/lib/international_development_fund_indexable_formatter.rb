require "abstract_indexable_formatter"

class InternationalDevelopmentFundIndexableFormatter < AbstractIndexableFormatter
  def type
    "international_development_fund"
  end

private
  def extra_attributes
    {
      application_state: entity.application_state,
      location: entity.location,
      development_sector: entity.development_sector,
      eligible_entities: entity.eligible_entities,
      value_of_fund: entity.value_of_fund,
    }
  end

  def organisation_slugs
    ["department-for-international-development"]
  end
end
