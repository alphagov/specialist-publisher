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
      location: entity.location,
      aircraft_type: entity.airccraft_type,
      registration: entity.registration,
    }
  end

  def organisation_slugs
    ["air-accidents-investigation-branch"]
  end
end
