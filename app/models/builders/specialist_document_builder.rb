class SpecialistDocumentBuilder
  def initialize(specialist_document_factory, id_generator)
    @document_factory = specialist_document_factory
    @id_generator = id_generator
  end

  def call(attrs)
    document_factory
      .call(new_document_id, editions)
      .tap { |d|
        d.update(attrs)
      }
  end

  private

  attr_reader :document_factory, :id_generator

  def new_document_id
    id_generator.call
  end

  def editions
    []
  end
end
