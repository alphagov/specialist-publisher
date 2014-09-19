require "preview_manual_document_service"
require "create_manual_document_service"
require "update_manual_document_service"
require "show_manual_document_service"
require "new_manual_document_service"

class ManualDocumentServiceRegistry
  def preview(context)
    PreviewManualDocumentService.new(
      manual_repository(context),
      manual_document_builder,
      document_renderer,
      context,
    )
  end

  def create(context)
    CreateManualDocumentService.new(
      manual_repository: manual_repository(context),
      listeners: [],
      context: context,
    )
  end

  def update(context)
    UpdateManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def show(context)
    ShowManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def new(context)
    NewManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

private
  def document_renderer
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  end

  def manual_repository_factory
    SpecialistPublisherWiring.get(:organisational_manual_repository_factory)
  end

  def manual_document_builder
    SpecialistPublisherWiring.get(:manual_document_builder)
  end

  def manual_repository(context)
    manual_repository_factory.call(context.current_organisation_slug)
  end
end
