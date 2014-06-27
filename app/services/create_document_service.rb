class CreateDocumentService
  def initialize(builder, repo, listeners, attributes)
    @builder = builder
    @repo = repo
    @listeners = listeners
    @attributes = attributes
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

  attr_reader :builder, :repo, :listeners, :attributes, :document

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end
end
