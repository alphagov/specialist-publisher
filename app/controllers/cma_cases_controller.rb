require "cma_case_service_registry"

class CmaCasesController < AbstractDocumentsController
private
  def document_params
    params.fetch("cma_case", {})
  end

  def view_adapter(document)
    CmaCaseViewAdapter.new(document)
  end

  def services
    CmaCaseServiceRegistry.new
  end

  def index_path
    cma_cases_path
  end

  def show_path(document)
    cma_case_path(document)
  end

  def document_type
    "cma_case"
  end
end
