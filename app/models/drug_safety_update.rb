class DrugSafetyUpdate < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    first_published_at
    therapeutic_area
  ].freeze

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
