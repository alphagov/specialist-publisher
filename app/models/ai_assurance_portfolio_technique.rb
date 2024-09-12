class AiAssurancePortfolioTechnique < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    use_case
    sector
    principle
    key_function
    ai_assurance_technique
    assurance_technique_approach
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
