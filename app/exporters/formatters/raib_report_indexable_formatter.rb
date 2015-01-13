require "formatters/abstract_specialist_document_indexable_formatter"

class RaibReportIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
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
    ["rail-accident-investigation-branch"]
  end
end
