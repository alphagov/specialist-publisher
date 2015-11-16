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
      format: document.format,
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      locale: "en",
      phase: document.phase,
      public_updated_at: document.public_updated_at,
      details: {
        body: document.body,
        metadata: metadata,
      },
      routes: [
        {
          path: document.base_path,
          type: "exact",
        }
      ],
      redirects: [],
      update_type: "major",
    }
  end

private

  attr_reader :document

  def metadata
    document.format_specific_fields.map do |f|
      {
        f => document.send(f)
      }
    end.reduce({}, :merge).merge(document_type: document.format)
  end

end
