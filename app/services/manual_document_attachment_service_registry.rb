class ManualDocumentAttachmentServiceRegistry < AbstractManualDocumentAttachmentServiceRegistry

private
  def repository
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end
end
