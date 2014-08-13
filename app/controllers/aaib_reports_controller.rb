require "aaib_report_service_registry"

class AaibReportsController < AbstractDocumentsController
private
  def view_adapter(document)
    AaibReportViewAdapter.new(document)
  end

  def services
    AaibReportServiceRegistry.new
  end

  def document_params
    filtered_params(params.fetch("aaib_report", {}))
  end

  def index_path
    aaib_reports_path
  end

  def show_path(document)
    aaib_report_path(document)
  end

  def document_type
    "aaib_report"
  end
end
