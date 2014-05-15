class NewManualDocumentService
  def initialize(manual_repository, document_builder, context)
    @manual_repository = manual_repository
    @document_builder = document_builder
    @context = context
  end

  def call
    [manual, new_document]
  end

  private

  attr_reader(
    :manual_repository,
    :document_builder,
    :context,
  )

  def new_document
    document_builder.call(initial_params)
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  def initial_params
    {}
  end
end
