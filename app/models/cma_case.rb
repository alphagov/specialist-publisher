class CmaCase < Document

  validates :opened_date, allow_blank: true, date: true
  validates :market_sector, presence: true
  validates :case_type, presence: true
  validates :case_state, presence: true
  validates :closed_date, allow_blank: true, date: true

  FORMAT_SPECIFIC_FIELDS = [
    :opened_date,
    :closed_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type
  ]

  attr_accessor *FORMAT_SPECIFIC_FIELDS

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def format
    "cma_case"
  end

  def self.format
    new.format
  end

  def public_path
    "/cma-cases"
  end
end
