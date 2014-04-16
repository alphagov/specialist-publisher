class PublishDocumentService
  def initialize(repo, listeners, context)
    @repo = repo
    @listeners = listeners
    @context = context
  end

  def call
    repo.publish!(document)

    document
  end

  private

  attr_reader :repo, :listeners, :context

  def persist
    repo.store!(document)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def document
    @document ||= repo.fetch(document_id)
  end

  def document_id
    context.params.fetch("id")
  end
end
