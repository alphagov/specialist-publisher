class DocumentAssociationMarshaller
  def initialize(dependencies = {})
    @decorator = dependencies.fetch(:decorator)
    @document_repository = dependencies.fetch(:document_repository)
  end

  def load(entity, record)
    docs = Array(record.document_ids).map do |id|
      document_repository.fetch(id)
    end

    decorator.call(entity, documents: docs)
  end

  def dump(entity, record)
    entity.documents.each do |doc|
      document_repository.store!(doc)
    end

    record.document_ids = entity.documents.map(&:id)

    nil
  end

private
  attr_reader :document_repository, :decorator
end
