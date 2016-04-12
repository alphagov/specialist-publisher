require 'govspeak'

class DocumentPresenter
  def initialize(document)
    @document = document
  end

  def to_json
    {
      content_id: document.content_id,
      base_path: document.base_path,
      title: document.title,
      description: document.summary,
      document_type: document.publishing_api_document_type,
      schema_name: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      locale: "en",
      phase: document.phase,
      public_updated_at: public_updated_at,
      details: details,
      routes: [
        {
          path: document.base_path,
          type: "exact",
        }
      ],
      redirects: [],
      update_type: document.update_type,
    }
  end

private

  attr_reader :document

  def details
    {
      body: GovspeakPresenter.present(document.body),
      metadata: metadata,
      change_history: change_history
    }.tap do |details_hash|
      details_hash[:attachments] = attachments if document.attachments
    end
  end

  def attachments
    document.attachments.map { |attachment| AttachmentPresenter.new(attachment).to_json }
  end

  def metadata
    merged_fields = document.format_specific_fields.map { |f|
      {
        f => document.send(f)
      }
    }.reduce({}, :merge)
      .merge(
        document_type: document.publishing_api_document_type,
        bulk_published: document.bulk_published,
      )

    merged_fields.reject { |_k, v| v.blank? }
  end

  def public_updated_at
    document.public_updated_at.to_datetime.rfc3339
  end

  def change_history
    case document.update_type
    when "major"
      document.change_history + [{ public_timestamp: public_updated_at, note: document.change_note || "First published." }]
    when "minor"
      document.change_history
    end
  end
end
