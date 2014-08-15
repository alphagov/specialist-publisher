class MedicalSafetyAlertAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:medical_safety_alert_repository)
  end
end
