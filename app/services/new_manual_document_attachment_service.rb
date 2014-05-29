class NewManualDocumentAttachmentService

  def initialize(manual_repository, builder, context)
    @manual_repository = manual_repository
    @builder = builder
    @context = context
  end

  def call
    [manual, document, attachment]
  end

  private

  attr_reader :manual_repository, :builder, :context

  def attachment
    builder.call(initial_params)
  end

  def document
    @document ||= manual.documents.find { |d| d.id == document_id }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def initial_params
    {}
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  def document_id
    context.params.fetch("document_id")
  end
end
