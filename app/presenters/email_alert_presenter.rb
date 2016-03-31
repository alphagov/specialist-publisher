class EmailAlertPresenter
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      subject: document.title + " updated",
      body: body,
      links: { topics: [document.content_id] },
      document_type: document.publishing_api_document_type,
    }.merge(extra_options)
  end

  def body
    view_renderer.render(
      template: "email_alerts/publication",
      formats: ["html"],
      locals:   {
        document_title: document.title,
        document_summary: document.summary,
        document_url: File.join(Plek.current.website_root, document.base_path),
        document_change_note: document.change_note,
      }
    )
  end

private

  def extra_options
    {
      header: header,
      footer: footer,
    }.reject { |_k, v| v.nil? }
  end

  def view_renderer
    ActionView::Base.new("app/views")
  end

  def header
    view_renderer.render(
      template: "email_alerts/publication_header",
      formats: ["html"],
    )
  end

  def footer
    view_renderer.render(
      template: "email_alerts/publication_footer",
      formats: ["html"],
    )
  end
end
