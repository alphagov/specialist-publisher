class CmaCase < Document
  validates :market_sector, presence: true
  validates :case_type, presence: true
  validates :case_state, presence: true
  validates :opened_date, allow_blank: true, date: true
  validates :closed_date, allow_blank: true, date: true
  validates_with OpenBeforeClosedValidator, opened_date: :opened_date, closed_date: :closed_date

  def self.title
    "CMA Case"
  end
end
