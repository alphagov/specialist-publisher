class MaibReport < Document
  validates :date_of_occurrence, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = [
    :date_of_occurrence,
    :report_type,
    :vessel_type,
  ]

  attr_accessor *FORMAT_SPECIFIC_FIELDS

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.document_type
    "maib_report"
  end
end
