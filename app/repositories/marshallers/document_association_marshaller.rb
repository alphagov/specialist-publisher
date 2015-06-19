class DocumentAssociationMarshaller
  def initialize(dependencies = {})
    @decorator = dependencies.fetch(:decorator)
    @manual_specific_document_repository_factory = dependencies.fetch(:manual_specific_document_repository_factory)
  end

  def load(manual, record)
    document_repository = manual_specific_document_repository_factory.call(manual)

    docs = Array(record.document_ids).map { |doc_id|
      document_repository.fetch(doc_id)
    }

    removed_docs = Array(record.removed_document_ids).map { |doc_id|
      document_repository.fetch(doc_id)
    }

    decorator.call(manual, documents: docs, removed_documents: removed_docs)
  end

  def dump(manual, record)
    document_repository = manual_specific_document_repository_factory.call(manual)

    manual.documents.each do |document|
      document_repository.store(document)
    end

    manual.removed_documents.each do |document|
      document_repository.store(document)
    end

    record.document_ids = manual.documents.map { |d| d.id }
    record.removed_document_ids = manual.removed_documents.map { |d| d.id }

    nil
  end

private
  attr_reader :manual_specific_document_repository_factory, :decorator
end
