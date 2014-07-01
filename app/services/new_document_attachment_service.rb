class NewDocumentAttachmentService

  def initialize(document_repository, builder, document_id)
    @document_repository = document_repository
    @builder = builder
    @document_id = document_id
  end

  def call
    [document, attachment]
  end

  private

  attr_reader :document_repository, :builder, :document_id

  def attachment
    builder.call(initial_params)
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def initial_params
    {}
  end
end
