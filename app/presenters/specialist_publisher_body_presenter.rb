class SpecialistPublisherBodyPresenter
  attr_reader :document

  def self.present(document)
    new(document).present
  end

  def initialize(document)
    @document = document
  end

  def present
    case document.body
    when Array
      body_content = document.body.find { |h| h[:content_type] == "text/govspeak" }
      govspeak_element[:content] = parse_body(body_content)
    when Hash
      body_content = document.body[:content]
      document.body[:content] = parse_body(body_content)
    else
      document.body = parse_body(document.body)
    end
    document.body
  end

private

  def parse_body(text)
    convert_images(text)
    convert_attachments(text)
    text
  end

  def convert_attachments(text)
    text.gsub!(/\[embed:attachments:inline:\s*(.+?)\s*\]/) do
      identifier = Regexp.last_match[1]
      inline_attachment_replacement(identifier)
    end
  end

  def convert_images(text)
    text.gsub!(/\[embed:attachments:image:\s*(.+?)\s*\]/) do
      identifier = Regexp.last_match[1]
      image_replacement(identifier)
    end
  end

  def inline_attachment_replacement(identifier)
    "[InlineAttachment:#{content_id_or_filename(identifier)}]"
  end

  def image_replacement(identifier)
    "![InlineAttachment:#{content_id_or_filename(identifier)}]"
  end

  def content_id_or_filename(identifier)
    attachment = document.attachments.detect do |att|
      att.content_id == identifier
    end
    attachment ? attachment.url.split("/").last : identifier
  end
end
