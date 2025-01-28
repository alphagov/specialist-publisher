class EsiFund < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    fund_state
    fund_type
    location
    funding_source
    closing_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
