class EmploymentAppealTribunalDecision < Document
  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_landmark, presence: true
  validates :tribunal_decision_sub_categories, presence: true

  FORMAT_SPECIFIC_FIELDS = [
    :hidden_indexable_content,
    :tribunal_decision_categories,
    :tribunal_decision_decision_date,
    :tribunal_decision_landmark,
    :tribunal_decision_sub_categories
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.publishing_api_document_type
    "employment_appeal_tribunal_decision"
  end
end
