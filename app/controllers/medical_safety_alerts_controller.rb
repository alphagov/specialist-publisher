require "medical_safety_alert_service_registry"

class MedicalSafetyAlertsController < AbstractDocumentsController
private
  def view_adapter(document)
    MedicalSafetyAlertViewAdapter.new(document)
  end

  def services
    MedicalSafetyAlertServiceRegistry.new
  end

  def document_params
    filtered_params(params.fetch("medical_safety_alert", {}))
  end

  def index_path
    medical_safety_alerts_path
  end

  def show_path(document)
    medical_safety_alert_path(document)
  end

  def document_type
    "medical_safety_alert"
  end
end
