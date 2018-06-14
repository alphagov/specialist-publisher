class StatutoryInstrument < Document
  validates :laid_date, date: true
  validates :sift_end_date, date: true
  validates :sifting_status, presence: true
  validates :subject, presence: true

  FORMAT_SPECIFIC_FIELDS = %i(
    laid_date
    sift_end_date
    sifting_status
    subject
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)
  attr_accessor :organisations

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    @organisations = params[:organisations]
  end

  def self.title
    "Statutory instrument"
  end

  def primary_publishing_organisation
    "fef4ac7c-024a-4943-9f19-e85a8369a1f3"
  end

  def links
    super.merge("organisations": organisations)
  end
end
