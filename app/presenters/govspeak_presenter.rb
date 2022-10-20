class GovspeakPresenter
  PRODUCTION_HOSTS = %w[www.gov.uk assets.publishing.service.gov.uk].freeze
  INTEGRATION_HOSTS = %w[www-origin.integration.publishing.service.gov.uk assets.digital.cabinet-office.gov.uk].freeze
  DEVELOPMENT_HOSTS = %w[assets-origin.dev.gov.uk].freeze
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
    internal_hosts = PRODUCTION_HOSTS + INTEGRATION_HOSTS + DEVELOPMENT_HOSTS
    attachments = document.attachments.map { |attachment| AttachmentPresenter.new(attachment).to_json }
    govspeak = Govspeak::Document.new(
      govspeak_body,
      attachments:,
      document_domains: internal_hosts,
    )
    govspeak.to_html
  end

  def snippets_match?(snippet_a, snippet_b)
    snippet_a = sanitise_snippet(snippet_a)
    snippet_b = sanitise_snippet(snippet_b)

    (snippet_a == snippet_b) && snippet_a.present?
  end

  def snippets_in_body
    @snippets_in_body ||= begin
      body = document.body
      matches = body.scan(/(\[InlineAttachment:.*?\])/)
      matches.flatten
    end
  end

  def sanitise_snippet(snippet)
    snippet = CGI.unescape(snippet)
    path = snippet[/\[\s*InlineAttachment\s*:\s*(.*?)\s*\]/, 1]
    return unless path

    special_chars = /[^a-zA-Z0-9]/
    filename = path.split("/").last
    filename = filename.downcase
    filename = filename.gsub(special_chars, "_")

    "[InlineAttachment:#{filename}]"
  end

private

  def replace_with_markdown_links(body, body_snippet, attachment)
    markdown_link = "[#{attachment.title}](#{attachment.url})"
    body.gsub(body_snippet, markdown_link)
  end
end
