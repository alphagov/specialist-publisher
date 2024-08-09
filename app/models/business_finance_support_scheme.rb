class BusinessFinanceSupportScheme < Document
  validates :business_sizes, presence: true
  validates :business_stages, presence: true
  validates :industries, presence: true
  validates :regions, presence: true
  validates :types_of_support, presence: true

  def self.exportable?
    true
  end

  def self.title
    "Business Finance Support Scheme"
  end
end
