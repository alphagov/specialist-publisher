class EmailAlertPresenter
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      subject: document.title + " updated",
      body: body,
      tags: tags,
      document_type: document.publishing_api_document_type,
    }.merge(extra_options)
  end

private

  def body
    if document.publishing_api_document_type == "medical_safety_alert"
      standard_body("email_alerts/medical_safety_alerts/publication")
    else
      standard_body("email_alerts/publication")
    end
  end

  def tags
    { format: document.publishing_api_document_type }.deep_merge(metadata)
  end

  def metadata
    merged_fields = document.format_specific_fields.map { |f|
      {
        f => document.send(f)
      }
    }.reduce({}, :merge)
    merged_fields.reject { |_k, v| v.blank? }
  end

  def standard_body(template_path)
    view_renderer.render(
      template: template_path,
      formats: ["html"],
      locals:   {
        document_title: document.title,
        document_summary: document.summary,
        document_url: File.join(Plek.current.website_root, document.base_path),
        document_change_note: document.change_note,
      }
    )
  end

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
