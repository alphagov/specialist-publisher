class GovspeakPresenter
  attr_accessor :document

  def initialize(document)
    @document = document
  end

  def present
    [
      { content_type: "text/govspeak", content: govspeak_body },
      { content_type: "text/html", content: html_body }
    ]
  end

  def html_body
    Govspeak::Document.new(govspeak_body_with_expanded_attachment_links).to_html
  end

private

  def govspeak_body
    document.body
  end

  def govspeak_body_with_expanded_attachment_links
    document.attachments.reduce(govspeak_body) { |body, attachment|
      body.gsub(attachment.snippet, attachment_markdown(attachment))
    }
  end

  def attachment_markdown(attachment)
    "[#{attachment.title}](#{attachment.url})"
  end
end
