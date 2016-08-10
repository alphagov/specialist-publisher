class UtaacDecision < Document
  FORMAT_SPECIFIC_FIELDS = [
    :indexable_content,
    :tribunal_decision_categories,
    :tribunal_decision_categories_name,
    :tribunal_decision_decision_date,
    :tribunal_decision_judges,
    :tribunal_decision_judges_name,
    :tribunal_decision_sub_categories,
    :tribunal_decision_sub_categories_name
  ]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Utaac Decision"
  end
end
