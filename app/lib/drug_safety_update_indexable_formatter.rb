require "abstract_indexable_formatter"

class DrugSafetyUpdateIndexableFormatter < AbstractIndexableFormatter
  def type
    "drug_safety_update"
  end

private
  def extra_attributes
    {
      therapeutic_area: entity.therapeutic_area,
      published_at: entity.published_at,
    }
  end

  def organisation_slugs
    ["medicines-and-healthcare-products-regulatory-agency"]
  end
end
