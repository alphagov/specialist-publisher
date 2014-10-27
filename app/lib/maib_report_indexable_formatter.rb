require "abstract_indexable_formatter"

class MaibReportIndexableFormatter < AbstractIndexableFormatter
  def type
    "maib_report"
  end

private
  def extra_attributes
    {
      date_of_occurrence: entity.date_of_occurrence,
      report_type: entity.report_type,
      vessel_type: entity.vessel_type,
    }
  end

  def organisation_slugs
    ["marine-accidents-investigation-branch"]
  end
end
