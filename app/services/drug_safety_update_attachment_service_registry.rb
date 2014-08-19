class DrugSafetyUpdateAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:drug_safety_update_repository)
  end
end
