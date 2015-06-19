require "remove_manual_document_service"

class ManualDocumentServiceRegistry
  def remove(context)
    RemoveManualDocumentService.new(
      manual_repository,
      context,
    )
  end

private
  def manual_repository
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end
end
