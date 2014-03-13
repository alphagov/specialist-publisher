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

  def attributes
    {
      headers: serialize_headers(headers)
    }.merge(doc.attributes)
  end

private

  attr_reader(
    :header_parser,
  )

  def doc
    __getobj__
  end

  def serialize_headers(headers)
    # TODO: Push this recursive serialization into Govspeak::StructuredHeader
    headers.map { |header|
      header.to_h.symbolize_keys.merge(
        headers: serialize_headers(header.headers)
      )
    }
  end
end
