class GovspeakPresenter
  attr_accessor :document

  PRODUCTION_HOSTS = %w(www.gov.uk assets.publishing.service.gov.uk)
  INTEGRATION_HOSTS = %w{www-origin.integration.publishing.service.gov.uk assets.digital.cabinet-office.gov.uk }

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
    internal_hosts = PRODUCTION_HOSTS + INTEGRATION_HOSTS

    Govspeak::Document.new(govspeak_body_with_expanded_attachment_links, document_domains: internal_hosts).to_html
  end

private

  def govspeak_body
    document.body
  end

  def govspeak_body_with_expanded_attachment_links
    body = replace_spaces_with_underscores_for_attachments(govspeak_body)

    document.attachments.reduce(body) { |b, attachment|
      b.gsub(attachment.snippet, attachment_markdown(attachment))
    }
  end

  def replace_spaces_with_underscores_for_attachments(string)
    string.gsub(/\[InlineAttachment(.*?)\]/) do |attachment_snippet|
      attachment_snippet.gsub(/\s/, "_")
    end
  end

  def attachment_markdown(attachment)
    "[#{attachment.title}](#{attachment.url})"
  end
end
