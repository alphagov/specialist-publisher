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

  def self.title
    "Export health certificate"
  end

  def primary_publishing_organisation
    "4ad67f14-6f9c-4fa4-80ab-687b6d81ea6f"
  end
end
