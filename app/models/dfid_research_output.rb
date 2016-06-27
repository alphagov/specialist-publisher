class DfidResearchOutput < Document
  validates :country, presence: true
  validates :first_published_at, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i(country first_published_at dfid_authors)

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    self.dfid_authors = []
  end

  ##
  # DFID research outputs are always bulk published, because our 'publication'
  # is just a proxy for a research output PDF. Its date is not important to a
  # user. Setting this +true+ means that specialist-frontend will never render
  # the publishing-api +published+ date.
  def bulk_published
    true
  end

  def self.title
    'DFID Research Output'
  end
end
