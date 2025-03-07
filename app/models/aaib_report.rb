class AaibReport < Document
  apply_validations
  validates :date_of_occurrence,
            presence: true,
            unless: lambda { |report|
                      report.report_type == "safety-study" && report.date_of_occurrence.blank?
                    }

  FORMAT_SPECIFIC_FIELDS = format_specific_fields

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end
end
