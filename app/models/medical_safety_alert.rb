class MedicalSafetyAlert < Document
  validates :alert_type, presence: true
  validates :issued_date, presence: true, date: true

  def self.title
    "Medical Safety Alert"
  end

  def urgent
    true
  end

  def email_footnote
    "If you have any questions about the medical content in this email, contact MHRA on info@mhra.gov.uk"
  end
end
