class TrafficCommissionerRegulatoryDecision < Document
  validates :decision_subject, presence: true
  validates :regions, presence: true
  validates :case_type, presence: true
  validates :outcome_type, presence: true
  validates :first_published_at, presence: true, date: true

  def self.title
    "Traffic Commissioner Regulatory Decision"
  end
end
