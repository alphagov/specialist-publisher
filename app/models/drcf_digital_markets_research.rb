class DrcfDigitalMarketsResearch < Document
  validates :digital_market_research_category, presence: true
  validates :digital_market_research_publisher, presence: true
  validates :digital_market_research_area, presence: true
  validates :digital_market_research_topic, presence: true
  validates :digital_market_research_publish_date,
            presence: true,
            date: true

  def self.title
    "DRCF digital markets research"
  end
end
