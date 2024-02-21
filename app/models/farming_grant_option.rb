class FarmingGrantOption < Document
  validates :grant_schemes, presence: true
  validates :payment_types, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    areas_of_interest
    land_types
    grant_schemes
    payment_types
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "Farming Grant Option"
  end

  def primary_publishing_organisation
    "de4e9dc6-cca4-43af-a594-682023b84d6c"
  end
end
