class EsiFund < Document
  validates :closing_date, allow_blank: true, date: true

  FORMAT_SPECIFIC_FIELDS = [
    :fund_state,
    :fund_type,
    :location,
    :funding_source,
    :closing_date,
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.publishing_api_document_type
    "esi_fund"
  end
end
