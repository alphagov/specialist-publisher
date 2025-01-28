class ProductSafetyAlertReportRecall < Document
  apply_validations

  FORMAT_SPECIFIC_FIELDS = format_specific_fields

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.admin_slug
    "product-safety-alerts-reports-recalls"
  end
end
