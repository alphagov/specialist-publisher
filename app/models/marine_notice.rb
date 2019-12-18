class MarineNotice < Document
  validates :issued_date, presence: true, date: true
  validates :marine_notice_type, presence: true
  validates :marine_notice_vessel_type, presence: true
  validates :marine_notice_topic, presence: true

  FORMAT_SPECIFIC_FIELDS = %i(
    marine_notice_type
    marine_notice_vessel_type
    marine_notice_topic
    issued_date
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Marine Notice"
  end

  def primary_publishing_organisation
    "23a24aa8-1711-42b6-bf6b-47af0f230295"
  end
end
