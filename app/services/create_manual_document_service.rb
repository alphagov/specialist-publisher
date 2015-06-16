class CreateManualDocumentService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @listeners = dependencies.fetch(:listeners)
    @context = dependencies.fetch(:context)
  end

  def call
    @new_document = manual.build_document(document_params)

    if new_document.valid?
      manual_repository.store(manual)
      notify_listeners
    end

    [manual, new_document]
  end

  private

  attr_reader :manual_repository, :listeners, :context

  attr_reader :new_document

  def manual
    @manual ||= manual_repository.fetch(context.params.fetch("manual_id"))
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(new_document, manual)
    end
  end

  def document_params
    context.params.fetch("document")
  end
end
