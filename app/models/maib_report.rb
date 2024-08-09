class MaibReport < Document
  validates :date_of_occurrence, presence: true, date: true

  def self.title
    "MAIB Report"
  end
end
