class TrademarkDecision < Document
  apply_validations

  # validates :grounds_sub_section, presence: true
  # validates_with OpenBeforeClosedValidator, issued_between: :issued_between, and: :and, browse_by_year: :browse_by_year

  FORMAT_SPECIFIC_FIELDS = format_specific_fields

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
