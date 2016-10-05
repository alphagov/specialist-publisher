class GovspeakPresenter
  PRODUCTION_HOSTS = %w(www.gov.uk assets.publishing.service.gov.uk)
  INTEGRATION_HOSTS = %w{www-origin.integration.publishing.service.gov.uk assets.digital.cabinet-office.gov.uk }
  DEVELOPMENT_HOSTS = %w{assets-origin.dev.gov.uk}
  attr_accessor :document

  def self.present(document)
    new(document).present
  end

  def initialize(document)
    @document = document
  end

  def present
    [{ content_type: "text/govspeak", content: govspeak_body }]
  end

  def govspeak_body
    GovspeakBodyPresenter.present(document)
  end

  def html_body
    body = document.body

    snippets_in_body.uniq.each do |body_snippet|
      document.attachments.each do |attachment|
        if snippets_match?(body_snippet, attachment.snippet)
          body = replace_with_markdown_links(body, body_snippet, attachment)
        end
      end
    end

    internal_hosts = PRODUCTION_HOSTS + INTEGRATION_HOSTS + DEVELOPMENT_HOSTS
    Govspeak::Document.new(body, document_domains: internal_hosts).to_html
  end

  def snippets_match?(a, b)
    a = sanitise(a)
    b = sanitise(b)

    (a == b) && a.present?
  end

  def snippets_in_body
    @snippets_in_body ||= (
      body = document.body
      matches = body.scan(/(\[InlineAttachment:.*?\])/)
      matches.flatten
    )
  end

private

  def replace_with_markdown_links(body, body_snippet, attachment)
    markdown_link = "[#{attachment.title}](#{attachment.url})"
    body.gsub(body_snippet, markdown_link)
  end

  def sanitise(snippet)
    snippet = CGI::unescape(snippet)
    path = snippet[/\[\s*InlineAttachment\s*:\s*(.*?)\s*\]/, 1]
    return unless path

    special_chars = /[^a-zA-Z0-9]/
    filename = path.split("/").last
    filename = filename.downcase
    filename = filename.gsub(special_chars, "_")

    "[InlineAttachment:#{filename}]"
  end
end
