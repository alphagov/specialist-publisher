class UpdateDocumentService
  def initialize(repo, listeners, context)
    @repo = repo
    @listeners = listeners
    @context = context
  end

  def call
    document.update(new_attributes)

    if document.valid?
      persist
      notify_listeners
    end

    document
  end

  private

  attr_reader :repo, :listeners, :context

  def persist
    repo.store(document)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def new_attributes
    context.params.fetch("specialist_document", {})
  end

  def document
    @document ||= repo.fetch(document_id)
  end

  def document_id
    context.params.fetch("id")
  end
end
