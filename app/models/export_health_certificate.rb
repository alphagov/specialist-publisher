class ExportHealthCertificate < Document
  validates :certificate_status, presence: true
  validates :commodity_type, presence: true
  validates :destination_country, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    certificate_status
    commodity_type
    destination_country
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
