require "delegate"
require "active_support/core_ext/hash"

class SpecialistDocumentHeaderExtractor < SimpleDelegator

  def initialize(header_parser, doc)
    @header_parser = header_parser
    super(doc)
  end

  def headers
    header_parser.call(doc.body)
  end

  def serialized_headers
    headers.map(&:to_h)
  end

  def attributes
    {
      headers: serialized_headers,
    }.merge(doc.attributes)
  end

private

  attr_reader(
    :header_parser,
  )

  def doc
    __getobj__
  end
end
