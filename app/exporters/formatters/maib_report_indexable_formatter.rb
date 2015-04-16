require "formatters/abstract_specialist_document_indexable_formatter"

class MaibReportIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
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
    ["marine-accident-investigation-branch"]
  end
end
