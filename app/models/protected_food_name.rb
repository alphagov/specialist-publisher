class ProtectedFoodName < Document
  validates :register_type, presence: true, date: true
  validates :product_type, presence: true, date: true
  validates :product_category, presence: true, date: true
  validates :file_number, presence: true, date: true
  validates :protection_type, presence: true, date: true
  validates :country, presence: true, date: true
  validates :status, presence: true, date: true
  validates :date_of_registration, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i(
    register_type
    product_type
    product_category
    file_number
    protection_type
    country
    status
    date_of_registration
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Protected Food Name"
  end

  def primary_publishing_organisation
    "de4e9dc6-cca4-43af-a594-682023b84d6c"
  end
end
