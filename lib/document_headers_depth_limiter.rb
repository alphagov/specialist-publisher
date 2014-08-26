require "delegate"

class DocumentHeadersDepthLimiter < SimpleDelegator
  def initialize(doc, args)
    super(doc)
    @doc = doc
    @max_depth = args.fetch(:depth)
  end

  def headers
    doc.headers
  end

  def serialized_headers
    limit_depth(doc.serialized_headers)
  end

  def attributes
    doc.attributes.merge(
      headers: serialized_headers,
    )
  end

  private

  attr_reader :doc, :max_depth

  def limit_depth(headers, current_depth = 1)
    if current_depth < max_depth
      headers.map { |h|
        h.merge(
          headers: limit_depth(h.fetch(:headers, []), current_depth + 1)
        )
      }
    else
      headers.map { |h| h.merge(headers: []) }
    end
  end
end
