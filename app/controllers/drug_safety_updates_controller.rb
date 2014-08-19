require "drug_safety_update_service_registry"

class DrugSafetyUpdatesController < AbstractDocumentsController
private
  def view_adapter(document)
    DrugSafetyUpdateViewAdapter.new(document)
  end

  def services
    DrugSafetyUpdateServiceRegistry.new
  end

  def document_params
    filtered_params(params.fetch("drug_safety_update", {}))
  end

  def index_path
    drug_safety_updates_path
  end

  def show_path(document)
    drug_safety_update_path(document)
  end

  def document_type
    "drug_safety_update"
  end
end
