class MarineNotice < Document
  validates :issued_date, presence: true, date: true
  validates :marine_notice_type, presence: true
  validates :marine_notice_vessel_type, presence: true
  validates :marine_notice_topic, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    marine_notice_type
    marine_notice_vessel_type
    marine_notice_topic
    issued_date
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
