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
      format: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      locale: "en",
      phase: document.phase,
      public_updated_at: public_updated_at,
      details: {
        body: document.body,
        metadata: metadata,
        change_history: change_history,
      },
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

  def metadata
    document.format_specific_fields.map do |f|
      {
        f => document.send(f)
      }
    end.reduce({}, :merge).merge(document_type: document.format).reject { |k, v| v.blank? }
  end

  def public_updated_at
    document.public_updated_at.to_s
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
