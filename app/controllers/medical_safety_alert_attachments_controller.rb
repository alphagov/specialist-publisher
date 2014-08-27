class MedicalSafetyAlertAttachmentsController < AbstractAttachmentsController

private
  def view_adapter(document)
    MedicalSafetyAlertViewAdapter.new(document)
  end

  def document_id
    params.fetch("medical_safety_alert_id")
  end

  def services
    MedicalSafetyAlertAttachmentServiceRegistry.new
  end

  def edit_path(document)
    edit_medical_safety_alert_path(document)
  end
end
