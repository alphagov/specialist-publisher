class ProductSafetyAlertReportRecall < Document
  validates :product_alert_type, presence: true
  validates :product_risk_level, presence: true
  validates :product_category, presence: true
  validates :product_measure_type, presence: true
  validates :product_recall_alert_date, allow_blank: true, date: true

  def self.title
    "Product Safety Alerts, Reports and Recalls"
  end

  def self.slug
    "product-safety-alerts-reports-recalls"
  end
end
