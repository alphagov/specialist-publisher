class NewDocumentService
  def initialize(document_builder)
    @document_builder = document_builder
  end

  def call
    document_builder.call(initial_params)
  end

  private

  attr_reader(
    :document_builder,
  )

  def initial_params
    {}
  end
end
