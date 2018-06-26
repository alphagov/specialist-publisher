class InternationalDevelopmentFund < Document
  FORMAT_SPECIFIC_FIELDS = %i(
    fund_state
    location
    development_sector
    eligible_entities
    value_of_funding
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    [INTERNATIONAL_AID_AND_DEVELOPMENT_TAXON_ID]
  end

  def self.title
    "International Development Fund"
  end

  def primary_publishing_organisation
    'db994552-7644-404d-a770-a2fe659c661f'
  end
end
