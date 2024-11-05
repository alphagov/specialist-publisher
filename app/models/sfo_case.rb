class SfoCase < Document
  validates :sfo_case_state, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    sfo_case_state
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
