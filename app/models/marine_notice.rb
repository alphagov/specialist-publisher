class MarineNotice < Document
  validates :issued_date, presence: true, date: true
  validates :marine_notice_type, presence: true
  validates :marine_notice_vessel_type, presence: true
  validates :marine_notice_topic, presence: true

  def self.title
    "Marine Notice"
  end
end
