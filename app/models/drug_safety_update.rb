class DrugSafetyUpdate < Document

  FORMAT_SPECIFIC_FIELDS = [
    :therapeutic_area,
    :first_published_at,
  ]

  attr_accessor *FORMAT_SPECIFIC_FIELDS

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.publishing_api_document_type
    "drug_safety_update"
  end
end
