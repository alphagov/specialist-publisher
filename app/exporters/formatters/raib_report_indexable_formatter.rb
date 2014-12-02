require "abstract_indexable_formatter"

class RaibReportIndexableFormatter < AbstractIndexableFormatter
  def type
    "raib_report"
  end

private
  def extra_attributes
    {
      date_of_occurrence: entity.date_of_occurrence,
      report_type: entity.report_type,
      railway_type: entity.railway_type,
    }
  end

  def organisation_slugs
    ["rail-accidents-investigation-branch"]
  end
end
