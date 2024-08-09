class AaibReport < Document
  validates :date_of_occurrence,
            presence: true,
            date: true,
            unless: lambda { |report|
                      report.report_type == "safety-study" && report.date_of_occurrence.blank?
                    }

  def self.title
    "AAIB Report"
  end
end
