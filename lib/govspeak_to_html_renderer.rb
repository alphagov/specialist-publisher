require "delegate"

class GovspeakToHTMLRenderer < SimpleDelegator

  def initialize(govspeak_html_converter, document)
    @govspeak_html_converter = govspeak_html_converter
    super(document)
  end

  def body
    govspeak_html_converter.call(document.body)
  end

  def attributes
    document.attributes.merge(
      body: body,
    )
  end

private

  attr_reader :govspeak_html_converter

  def document
    __getobj__
  end
end
