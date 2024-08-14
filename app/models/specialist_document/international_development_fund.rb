class SpecialistDocument::InternationalDevelopmentFund < Document
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
end
