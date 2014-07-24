class CmaCaseAttachmentServiceRegistry < AbstractAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:cma_case_repository)
  end
end
