class FarmingGrant < Document
  validates :payment_types, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    areas_of_interest
    land_types
    payment_types
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
