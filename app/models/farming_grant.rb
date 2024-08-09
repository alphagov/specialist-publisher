class FarmingGrant < Document
  validates :payment_types, presence: true

  def self.title
    "Farming Grant"
  end
end
