class GovspeakBodyPresenter
  attr_reader :document

  def self.present(document)
    new(document).present
  end

  def initialize(document)
    @document = document
  end

  def present
    formatted = format_images_for_publishing_api(document.body)
    format_inline_attachments_for_publishing_api(formatted)
  end

  def format_images_for_publishing_api(text)
    text.gsub(/!\[InlineAttachment:(.+?)\]/) do
      filename = Regexp.last_match[1]
      inline_attachment_replacement(filename, "image")
    end
  end

  def format_inline_attachments_for_publishing_api(text)
    text.gsub(/\[InlineAttachment:(.+?)\]/) do
      filename = Regexp.last_match[1]
      inline_attachment_replacement(filename, "inline")
    end
  end

  def inline_attachment_replacement(filename, attachment_type)
    attachment = matching_attachment(filename)
    identifier = attachment ? attachment.content_id : filename
    "[embed:attachments:#{attachment_type}:#{identifier}]"
  end

  def matching_attachment(filename)
    document.attachments.detect do |att|
      att.url.split("/").last == filename
    end
  end
end
