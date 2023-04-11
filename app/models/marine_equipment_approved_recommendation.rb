class MarineEquipmentApprovedRecommendation < Document
  validates :year_adopted, format: /\A$|[1-9][0-9]{3}\z/

  FORMAT_SPECIFIC_FIELDS = %i[
    category
    year_adopted
    reference_number
    keyword
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "Marine Equipment Approved Recommendation"
  end

  def primary_publishing_organisation
    "23a24aa8-1711-42b6-bf6b-47af0f230295"
  end
end
