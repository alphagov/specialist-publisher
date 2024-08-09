class TaxTribunalDecision < Document
  validates :tribunal_decision_category, presence: true
  validates :tribunal_decision_decision_date, allow_blank: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    hidden_indexable_content
    tribunal_decision_category
    tribunal_decision_decision_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Tax Tribunal Decision"
  end

  def primary_publishing_organisation
    "6f757605-ab8f-4b62-84e4-99f79cf085c2"
  end
end
