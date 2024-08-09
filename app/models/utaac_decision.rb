class UtaacDecision < Document
  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_sub_categories, presence: false
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_judges, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    hidden_indexable_content
    tribunal_decision_categories
    tribunal_decision_decision_date
    tribunal_decision_judges
    tribunal_decision_sub_categories
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "UTAAC Decision"
  end

  def primary_publishing_organisation
    "6f757605-ab8f-4b62-84e4-99f79cf085c2"
  end
end
