module SpecialistPublisher
  extend self

  def attachment_services(document_type)
    AbstractAttachmentServiceRegistry.new(
      repository: document_repositories.for_type(document_type)
    )
  end

  def view_adapter(document)
    view_adapters.for_document(document)
  end
private

  def view_adapters
    SpecialistPublisherWiring.get(:view_adapter_registry)
  end

  def document_repositories
    SpecialistPublisherWiring.get(:repository_registry)
  end
end
