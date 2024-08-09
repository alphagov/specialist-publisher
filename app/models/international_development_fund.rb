class InternationalDevelopmentFund < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    fund_state
    location
    development_sector
    eligible_entities
    value_of_funding
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "International Development Fund"
  end

  def primary_publishing_organisation
    "f9fcf3fe-2751-4dca-97ca-becaeceb4b26"
  end
end
