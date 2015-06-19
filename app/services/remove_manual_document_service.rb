class RemoveManualDocumentService
  def initialize(manual_repository, context)
    @manual_repository = manual_repository
    @context = context
  end

  def call
    validate_never_published

    remove
    persist

    [manual, document]
  end

private
  attr_reader :manual_repository, :context

  def validate_never_published
    raise PreviouslyPublishedError if document.published?
  end

  def remove
    manual.remove_document(document_id)
  end

  def persist
    manual_repository.store(manual)
  end

  def document
    @document ||= manual.documents.find { |d| d.id == document_id }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def document_id
    context.params.fetch("id")
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  class PreviouslyPublishedError < StandardError; end
end
