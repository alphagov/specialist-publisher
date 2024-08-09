class AlgorithmicTransparencyRecord < Document
  validates :algorithmic_transparency_record_organisation, presence: true
  validates :algorithmic_transparency_record_organisation_type, presence: true
  validates :algorithmic_transparency_record_phase, presence: true
  validates :algorithmic_transparency_record_date_published, presence: true
  validates :algorithmic_transparency_record_atrs_version, presence: true

  def self.title
    "Algorithmic transparency record"
  end
end
