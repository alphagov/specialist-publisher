class CmaCase < Document
  FORMAT_SPECIFIC_FIELDS = [
    :opened_date,
    :closed_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type
  ]

  attr_accessor *FORMAT_SPECIFIC_FIELDS

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def format
    "cma_case"
  end

  def public_path
    "/cma-cases"
  end
end
