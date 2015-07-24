require "plek"
require "action_view"
require "yaml"

class AbstractDocumentPublicationAlertFormatter
  def initialize(dependencies = {})
    @document = dependencies.fetch(:document)
    @url_maker = dependencies.fetch(:url_maker)
  end

  def name
    raise NotImplementedError
  end

  def tags
    arrayified_extra_fields.merge(
      format: [format]
    )
  end

  def subject
    document.title
  end

  def body
    view_renderer.render(
      template: "email_alerts/publication",
      formats: ["html"],
      locals: html_body_local_assigns
    )
  end

  def extra_options
    {
      header: header,
      footer: footer,
      urgent: urgent,
      from_address_id: from_address_id,
    }.reject { |_k, v| v.nil? }
  end

private
  attr_reader(
    :document,
    :url_maker,
  )

  def html_body_local_assigns
    {
      human_document_type: name,
      document_noun: document_noun,
      updated_or_published: updated_or_published_text,
      document_title: document.title,
      document_summary: document.summary,
      document_url: url_maker.published_specialist_document_path(document),
      document_change_note: document_change_note,
    }
  end

  def document_noun
    raise NotImplementedError
  end

  def format
    document.document_type
  end

  def view_renderer
    ActionView::Base.new("app/views")
  end

  def updated_or_published_text
    document.version_number == 1 ? "published" : "updated"
  end

  def document_change_note
    document.change_note if document.version_number != 1
  end

  def extra_fields
    document.extra_fields
  end

  def arrayified_extra_fields
    hash = {}
    extra_fields.each { |key, value| hash[key] = value.is_a?(Array) ? value : [value] }
    hash
  end

  def header
    nil
  end

  def footer
    nil
  end

  def urgent
    # DO NOT set default to false, this will send false to gov delivery
    # and FORCE overriding of topic defaults set in gov delivery
    # This should only be overridden where we explicitly want an
    # email to be non urgent and not to fallback to gov delivery defaults
    nil
  end

  def from_address_id
    from_address_config[document.document_type]
  end

  def from_address_config
    @config ||= YAML.load_file(File.join(Rails.root, "config", "gov_delivery_from_address_ids.yml"))[Rails.env]
  end

  def header
    view_renderer.render(
      template: "email_alerts/publication_header",
      formats: ["html"],
      locals: {
        human_document_type: name
      }
    )
  end

  def footer
    view_renderer.render(
      template: "email_alerts/publication_footer",
      formats: ["html"],
    )
  end
end
