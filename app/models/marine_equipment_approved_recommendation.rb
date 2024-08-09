class MarineEquipmentApprovedRecommendation < Document
  validates :year_adopted, format: /\A$|[1-9][0-9]{3}\z/

  def self.title
    "Marine Equipment Approved Recommendation"
  end
end
