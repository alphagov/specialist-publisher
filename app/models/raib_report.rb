class RaibReport < Document
  apply_validations

  FORMAT_SPECIFIC_FIELDS = %i[
    date_of_occurrence
    report_type
    railway_type
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
