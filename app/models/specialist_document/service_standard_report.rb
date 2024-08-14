class SpecialistDocument::ServiceStandardReport < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    assessment_date
    result
    stage
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
