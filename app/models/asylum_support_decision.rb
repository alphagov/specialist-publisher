class AsylumSupportDecision < Document
  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_judges, presence: true
  validates :tribunal_decision_landmark, presence: true
  validates :tribunal_decision_reference_number, presence: true
  validates :tribunal_decision_sub_categories, presence: true, asylum_support_decision_sub_category: true

  FORMAT_SPECIFIC_FIELDS = %i[
    hidden_indexable_content
    tribunal_decision_category
    tribunal_decision_categories
    tribunal_decision_decision_date
    tribunal_decision_judges
    tribunal_decision_landmark
    tribunal_decision_reference_number
    tribunal_decision_sub_category
    tribunal_decision_sub_categories
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Asylum Support Decisions"
  end
end
