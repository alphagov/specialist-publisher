class CreateDocumentService
  def initialize(builder, repo, listeners, context)
    @builder = builder
    @repo = repo
    @listeners = listeners
    @context = context
  end

  def call
    document = builder.call(attributes)

    if document.valid?
      repo.store!(document)
    end

    document
  end

  private

  attr_reader :builder, :repo, :listeners, :context

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def attributes
    context.params.fetch("specialist_document", {})
  end
end
