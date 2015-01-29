require "formatters/abstract_specialist_document_indexable_formatter"

class CountrysideStewardshipGrantIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "countryside_stewardship_grant"
  end

  private
  def extra_attributes
    {
      grant_type: entity.grant_type,
      land_use: entity.land_use,
      tiers_or_standalone_items: entity.tiers_or_standalone_items,
      funding_amount: entity.funding_amount,
    }
  end

  def organisation_slugs
    %w(
      natural-england
      department-for-environment-food-rural-affairs
      forestry-commission
    )
  end
end
