require "show_manual_document_service"
require "remove_manual_document_service"

class ManualDocumentServiceRegistry
  def show(context)
    ShowManualDocumentService.new(
      manual_repository,
      context,
    )
  end

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
