require "formatters/abstract_specialist_document_indexable_formatter"

class CountrysideStewardshipGrantIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "countryside_stewardship_grant"
  end

  private
  def extra_attributes
    {}
  end

  def organisation_slugs
    %w(
      natural-england
      department-for-environment-food-rural-affairs
      forestry-commission
    )
  end
end
