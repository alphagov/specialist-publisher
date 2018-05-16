class CountrysideStewardshipGrant < Document
  FORMAT_SPECIFIC_FIELDS = %i(
    grant_type
    land_use
    tiers_or_standalone_items
    funding_amount
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Countryside Stewardship Grant"
  end

  def primary_publishing_organisation
    "d3ce4ba7-bc75-46b4-89d9-38cb3240376d"
  end
end
