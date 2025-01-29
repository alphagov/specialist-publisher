class TaxTribunalDecision < Document
  apply_validations

  FORMAT_SPECIFIC_FIELDS = %i[
    hidden_indexable_content
    tribunal_decision_category
    tribunal_decision_decision_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
