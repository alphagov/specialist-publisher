class EmailAlertPresenter

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      subject: document.title + " updated",
      body: header + body + footer,
      links: [document.content_id],
      document_type: document.publishing_api_document_type,
    }
  end

  def body
    view_renderer.render(
      template: "email_alerts/publication",
      formats: ["html"],
      locals:   {
        document_title: document.title,
        document_summary: document.summary,
        document_url: [Plek.current.website_root, document.base_path].join(""),
        document_change_note: document.change_note,
      }
    )
  end

  private

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