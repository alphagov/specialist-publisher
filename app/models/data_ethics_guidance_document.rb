class DataEthicsGuidanceDocument < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    data_ethics_guidance_document_ethical_theme
    data_ethics_guidance_document_organisation_alias
    data_ethics_guidance_document_project_phase
    data_ethics_guidance_document_technology_area
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
