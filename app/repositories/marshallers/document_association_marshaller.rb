class DocumentAssociationMarshaller
  def initialize(dependencies = {})
    @decorator = dependencies.fetch(:decorator)
    @document_repository = dependencies.fetch(:document_repository)
  end

  def load(entity, record)
    docs = Array(record.document_ids).map { |doc_id|
      document_repository.fetch(doc_id)
    }

    decorator.call(entity, documents: docs)
  end

  def dump(entity, record)
    entity.documents.each do |document|
      document_repository.store(document)
    end

    record.document_ids = entity.documents.map { |d| d.id }

    nil
  end

private
  attr_reader :document_repository, :decorator
end
