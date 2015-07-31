class ReorderManualDocumentsService
  def initialize(manual_repository, context, listeners:)
    @manual_repository = manual_repository
    @context = context
    @listeners = listeners
  end

  def call
    update
    persist
    notify_listeners

    [manual, documents]
  end

private
  attr_reader :manual_repository, :context, :listeners

  def update
    manual.reorder_documents(document_order)
  end

  def persist
    manual_repository.store(manual)
  end

  def documents
    manual.documents
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  def document_order
    context.params.fetch("section_order")
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(nil, manual)
    end
  end
end
