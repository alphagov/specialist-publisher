require "aaib_report_service_registry"

class AaibReportsController < AbstractDocumentsController
private
  def view_adapter(document)
    AaibReportViewAdapter.new(document)
  end

  def authorize_user
    unless user_can_edit_aaib_reports?
      redirect_to(
        manuals_path,
        flash: { error: "You don't have permission to do that." },
      )
    end
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
end
