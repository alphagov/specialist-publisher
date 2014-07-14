require "cma_case_service_registry"

class CmaCasesController < AbstractDocumentsController
private
  def document_params
    params.fetch("cma_case", {})
  end

  def form_object_for(document)
    CmaCaseForm.new(document)
  end

  def authorize_user
    unless user_can_edit_cma_cases?
      redirect_to(
        manuals_path,
        flash: { error: "You don't have permission to do that." },
      )
    end
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
end
