class FarmingGrantOption < Document
  validates :open_or_closed, presence: true
  validates :areas_of_interest, presence: true
  validates :land_types, presence: true
  validates :funding_types, presence: true
  validates :grant_schemes, presence: true
  validates :payment_types, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    open_or_closed
    areas_of_interest
    land_types
    funding_types
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
