class AnimalDiseaseCase < Document
  validates :disease_type, presence: true
  validates :zone_restriction, presence: true
  validates :zone_type, presence: true
  validates :disease_case_opened_date, presence: true, date: true
  validates :disease_case_closed_date, date: true
  validates_with OpenBeforeClosedValidator, opened_date: :disease_case_opened_date, closed_date: :disease_case_closed_date

  def self.title
    "Animal disease case"
  end
end
