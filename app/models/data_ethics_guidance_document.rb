class DataEthicsGuidanceDocument < Document
  validates :key_reference, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    key_reference
    ethical_theme
    organisation
    document_function
    project_phase
    technology_area
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
