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
end
