require "publish_document_service"
require "update_document_service"
require "create_document_service"

class ServiceRegistry

  def initialize(document_builder, document_repository, publication_listeners)
    @document_builder = document_builder
    @document_repository = document_repository
    @publication_listeners = publication_listeners
  end

  def create_document(context)
    CreateDocumentService.new(
      document_builder,
      document_repository,
      [],
      context,
    )
  end

  def publish_document(context)
    PublishDocumentService.new(
      document_repository,
      publication_listeners,
      context,
    )
  end

  def update_document(context)
    UpdateDocumentService.new(
      document_repository,
      [],
      context,
    )
  end

  private

  attr_reader(
    :document_builder,
    :document_repository,
    :publication_listeners,
  )
end
