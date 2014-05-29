class NewDocumentAttachmentService

  def initialize(document_repository, builder, context)
    @document_repository = document_repository
    @builder = builder
    @context = context
  end

  def call
    [document, attachment]
  end

  private

  attr_reader :document_repository, :builder, :context

  def attachment
    builder.call(initial_params)
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def initial_params
    {}
  end

  def document_id
    context.params.fetch("specialist_document_id")
  end
end
