require "plek"

class AbstractDocumentPublicationAlertFormatter
  def initialize(dependencies = {})
    @document = dependencies.fetch(:document)
    @url_maker = dependencies.fetch(:url_maker)
  end

  def identifier
    "#{Plek.current.find("finder-frontend")}/#{slug_prefix}.atom"
  end

  def subject
    "#{human_document_type}: #{document.title}"
  end

  def body
    view_renderer.render(
      template: "email_alerts/publication.txt",
      locals: {
        human_document_type: human_document_type,
        document_noun: document_noun,
        updated_or_published: updated_or_published_text,
        document_title: document.title,
        document_summary: document.summary,
        document_url: url_maker.published_specialist_document_path(document),
      }
    )
  end

private
  attr_reader(
    :document,
    :url_maker,
  )

  def human_document_type
    raise NotImplementedError
  end

  def document_noun
    raise NotImplementedError
  end

  def slug_prefix
    document.slug.split("/").first
  end

  def view_renderer
    ActionView::Base.new(File.join(Rails.root, "app/views"))
  end

  def updated_or_published_text
    document.version_number == 1 ? "published" : "updated"
  end
end
