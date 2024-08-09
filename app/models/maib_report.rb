class MaibReport < Document
  validates :date_of_occurrence, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    date_of_occurrence
    report_type
    vessel_type
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "MAIB Report"
  end

  def primary_publishing_organisation
    "9c66b9a3-1e6a-48e8-974d-2a5635f84679"
  end
end
