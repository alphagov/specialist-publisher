class RaibReport < Document
  validates :date_of_occurrence, presence: true, date: true

  def self.title
    "RAIB Report"
  end
end
