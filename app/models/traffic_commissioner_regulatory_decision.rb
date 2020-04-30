class TrafficCommissionerRegulatoryDecision < Document
  validates :decision_subject, presence: true
  validates :regions, presence: true
  validates :case_type, presence: true
  validates :outcome_type, presence: true
  validates :first_published_at, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    decision_subject
    regions
    case_type
    outcome_type
    first_published_at
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Traffic Commissioner Regulatory Decision"
  end

  def primary_publishing_organisation
    "78dfc32b-b1ef-44ca-924c-a2cf773e87ca"
  end
end
