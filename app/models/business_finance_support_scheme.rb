class BusinessFinanceSupportScheme < Document
  apply_validations
  validates :continuation_link, presence: true

  FORMAT_SPECIFIC_FIELDS = format_specific_fields + %i[continuation_link will_continue_on]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.exportable?
    true
  end
end
