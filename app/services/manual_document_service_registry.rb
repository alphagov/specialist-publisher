class ManualDocumentServiceRegistry < AbstractManualDocumentServiceRegistry

private
  def manual_repository
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end
end
