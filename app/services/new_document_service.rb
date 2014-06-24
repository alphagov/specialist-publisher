class NewDocumentService
  def initialize(document_builder, context, document_type)
    @document_builder = document_builder
    @document_type = document_type
  end

  def call
    document_builder.call(initial_params)
  end

  private

  attr_reader(
    :document_builder,
    :document_type,
  )

  def initial_params
    {
      document_type: document_type,
    }
  end
end
