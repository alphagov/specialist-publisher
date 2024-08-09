class EsiFund < Document
  validates :closing_date, allow_blank: true, date: true

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

  def self.title
    "ESI Fund"
  end

  def primary_publishing_organisation
    "2e7868a8-38f5-4ff6-b62f-9a15d1c22d28"
  end
end
