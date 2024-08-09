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

  def self.title
    "Portfolio of Assurance Techniques"
  end

  def primary_publishing_organisation
    "c352c234-8083-47ec-8a4b-0edd45c31263"
  end
end
