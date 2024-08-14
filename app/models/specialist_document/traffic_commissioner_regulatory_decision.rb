class SpecialistDocument::TrafficCommissionerRegulatoryDecision < Document
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
end
