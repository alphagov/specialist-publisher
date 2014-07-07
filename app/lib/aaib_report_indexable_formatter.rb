require "abstract_indexable_formatter"

class AaibReportIndexableFormatter < AbstractIndexableFormatter
  def type
    "aaib_report"
  end

private
  def extra_attributes
    {
      aircraft_category: entity.aircraft_category,
      report_type: entity.report_type,
      date_of_occurrence: entity.date_of_occurrence,
    }
  end

  def organisation_slugs
    ["air-accidents-investigation-branch"]
  end
end
