class DfidResearchOutput < Document
  validates :country, presence: true
  validates :first_published_at, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i(country first_published_at)

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    'DFID Research Output'
  end
end
