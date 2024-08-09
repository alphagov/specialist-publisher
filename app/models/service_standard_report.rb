class ServiceStandardReport < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    assessment_date
    result
    stage
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Service Standard Report"
  end

  def primary_publishing_organisation
    "2fb482e7-3c4d-496f-887d-f8a55a15e89a"
  end
end
