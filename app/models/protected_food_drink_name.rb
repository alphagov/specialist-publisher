class ProtectedFoodDrinkName < Document
  apply_validations
  validates :time_registration, time: true

  FORMAT_SPECIFIC_FIELDS = format_specific_fields

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.admin_slug
    "protected-food-drink-names"
  end
end
