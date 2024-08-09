class ExportHealthCertificate < Document
  validates :certificate_status, presence: true
  validates :commodity_type, presence: true
  validates :destination_country, presence: true

  def self.title
    "Export health certificate"
  end
end
