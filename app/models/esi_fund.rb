class EsiFund < Document
  validates :closing_date, allow_blank: true, date: true

  def self.title
    "ESI Fund"
  end
end
