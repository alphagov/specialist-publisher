class CountrysideStewardshipGrant < Document
  FORMAT_SPECIFIC_FIELDS = %i(
    grant_type
    land_use
    tiers_or_standalone_items
    funding_amount
  )

  attr_accessor *FORMAT_SPECIFIC_FIELDS

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.publishing_api_document_type
    "countryside_stewardship_grant"
  end
end
