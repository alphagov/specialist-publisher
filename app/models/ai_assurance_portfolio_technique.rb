class AiAssurancePortfolioTechnique < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    use_case
    sector
    principle
    key_function
    ai_assurance_technique
    assurance_technique_approach
    focus_sector
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "Portfolio of Assurance Techniques"
  end

  def primary_publishing_organisation
    "1405edcb-943d-42d2-8ec8-c51cd58335a5"
  end
end
