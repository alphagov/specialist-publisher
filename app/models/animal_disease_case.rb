class AnimalDiseaseCase < Document
  validates :disease_type, presence: true
  validates :zone_restriction, presence: true
  validates :zone_type, presence: true
  validates :disease_case_opened_date, presence: true, date: true
  validates :disease_case_closed_date, date: true
  validates_with OpenBeforeClosedValidator, opened_date: :disease_case_opened_date, closed_date: :disease_case_closed_date

  FORMAT_SPECIFIC_FIELDS = %i[
    disease_type
    zone_restriction
    zone_type
    virus_strain
    disease_case_closed_date
    disease_case_opened_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
