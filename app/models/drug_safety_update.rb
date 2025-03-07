class DrugSafetyUpdate < Document
  apply_validations
  FORMAT_SPECIFIC_FIELDS = format_specific_fields

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def send_email_on_publish?
    false
  end
end
