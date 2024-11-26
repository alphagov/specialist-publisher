class SfoCase < Document
  validates :sfo_case_state, presence: true
  validates :sfo_case_date_announced, presence: true, date: true

  FORMAT_SPECIFIC_FIELDS = %i[
    sfo_case_state
    sfo_case_date_announced
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
