class DrugSafetyUpdate < Document
  FORMAT_SPECIFIC_FIELDS = [
    :therapeutic_area,
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Drug Safety Update"
  end

  def send_email_on_publish?
    false
  end
end
