require "securerandom"

class SpecialistDocumentBuilder
  def initialize(document_type, specialist_document_factory)
    @document_type = document_type
    @document_factory = specialist_document_factory
  end

  def call(attrs)
    document_factory.call(SecureRandom.uuid, editions).
      tap { |d| d.update(attrs.merge(defaults)) }
  end

private

  attr_reader(
    :document_type,
    :document_factory,
  )

  def editions
    []
  end

  def defaults
    {
      document_type: document_type,
      change_note: "First published.",
    }
  end
end
