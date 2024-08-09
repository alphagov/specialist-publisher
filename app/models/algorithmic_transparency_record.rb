class AlgorithmicTransparencyRecord < Document
  validates :algorithmic_transparency_record_organisation, presence: true
  validates :algorithmic_transparency_record_organisation_type, presence: true
  validates :algorithmic_transparency_record_phase, presence: true
  validates :algorithmic_transparency_record_date_published, presence: true
  validates :algorithmic_transparency_record_atrs_version, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    algorithmic_transparency_record_organisation
    algorithmic_transparency_record_organisation_type
    algorithmic_transparency_record_function
    algorithmic_transparency_record_capability
    algorithmic_transparency_record_task
    algorithmic_transparency_record_phase
    algorithmic_transparency_record_region
    algorithmic_transparency_record_date_published
    algorithmic_transparency_record_atrs_version
    algorithmic_transparency_record_other_tags
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Algorithmic transparency record"
  end
end
