class CreateDocumentService
  def initialize(builder, repo, listeners, context, document_type)
    @builder = builder
    @repo = repo
    @listeners = listeners
    @context = context
    @document_type = document_type
  end

  def call
    @document = builder.call(attributes)

    if document.valid?
      repo.store(document)
      notify_listeners
    end

    document
  end

  private

  attr_reader :builder, :repo, :listeners, :context, :document, :document_type

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def attributes
    context.params
      .fetch("specialist_document", {})
      .merge(document_type: document_type)
  end
end
