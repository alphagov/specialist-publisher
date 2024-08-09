class EmploymentTribunalDecision < Document
  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_country, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    hidden_indexable_content
    tribunal_decision_categories
    tribunal_decision_country
    tribunal_decision_decision_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "ET Decision"
  end

  def self.slug
    "employment-tribunal-decisions"
  end

  def primary_publishing_organisation
    "6f757605-ab8f-4b62-84e4-99f79cf085c2"
  end
end
