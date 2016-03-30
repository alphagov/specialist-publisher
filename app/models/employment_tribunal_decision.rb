class EmploymentTribunalDecision < Document
  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_country, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = [
    :hidden_indexable_content,
    :tribunal_decision_categories,
    :tribunal_decision_country,
    :tribunal_decision_decision_date
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.publishing_api_document_type
    "employment_tribunal_decision"
  end
end
