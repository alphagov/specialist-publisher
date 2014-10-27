require "securerandom"

class SpecialistDocumentBuilder
  def initialize(specialist_document_factory)
    @document_factory = specialist_document_factory
  end

  def call(attrs)
    document_factory.call(SecureRandom.uuid, editions).tap { |d| d.update(attrs) }
  end

  private

  attr_reader :document_factory

  def editions
    []
  end
end
