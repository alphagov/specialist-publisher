class TypeExaminationCertificate < Document
  validates :certificate, presence: true
  validates :issuing_body, presence: true
  validates :applicant, presence: true
  validates :instrument_category, presence: true
  validates :instrument_designation, presence: true
  validates :current_version, presence: true
  validates :date_issued, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i(
    certificate
    issuing_body
    applicant
    instrument_category
    instrument_designation
    current_version
    date_issued
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Metrology Type Examination Certificate"
  end

  def self.slug
    "type_examination_certificates"
  end

  def primary_publishing_organisation
    "2bde479a-97f2-42b5-986a-287a623c2a1c"
  end
end