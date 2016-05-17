class DfidResearchOutput < Document
  validates :country, presence: true

  FORMAT_SPECIFIC_FIELDS = %i(country)

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    'DFID Research Output'
  end
end
