class RaibReport < Document
  validates :date_of_occurrence, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    date_of_occurrence
    report_type
    railway_type
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "RAIB Report"
  end

  def primary_publishing_organisation
    "013872d8-8bbb-4e80-9b79-45c7c5cf9177"
  end
end
