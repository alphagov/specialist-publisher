class SpecialistDocumentPublishingApiFormatter
  attr_reader :specialist_document, :specialist_document_renderer, :publication_logs

  def initialize(specialist_document, specialist_document_renderer: , publication_logs: )
    @specialist_document = specialist_document
    @specialist_document_renderer = specialist_document_renderer
    @publication_logs = publication_logs
  end

  def call
    {
      content_id: specialist_document.id,
      format: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      title: rendered_document_attributes.fetch(:title),
      description: rendered_document_attributes.fetch(:summary),
      update_type: update_type,
      locale: "en",
      public_updated_at: public_updated_at,
      details: {
        metadata: metadata,
        change_history: change_history,
        body: rendered_document_attributes[:body]
      }.merge(headers),
      routes: [
        path: base_path,
        type: 'exact'
      ]
    }
  end

  private

  def rendered_document_attributes
    @rendered_document_attributes ||= specialist_document_renderer.call(specialist_document).attributes
  end

  def metadata
    rendered_document_attributes[:extra_fields].merge(document_type: specialist_document.document_type)
  end

  def public_updated_at
    # Editions only get a public_updated_at when they are published, so field
    # can be blank.
    specialist_document.public_updated_at || specialist_document.updated_at
  end

  def update_type
    specialist_document.minor_update? ? "minor" : "major"
  end

  def change_history
    publication_logs.change_notes_for(specialist_document.slug).map do |log|
      {
        public_timestamp: log.published_at.iso8601,
        note: log.change_note,
      }
    end
  end

  def base_path
    "/#{specialist_document.attributes[:slug]}"
  end

  def headers
    strip_empty_header_lists(
      :headers => rendered_document_attributes[:headers]
    )
  end

  def strip_empty_header_lists(header_struct)
    if header_struct[:headers].any?
      header_struct.merge(:headers => header_struct[:headers].map {|h| strip_empty_header_lists(h)} )
    else
      header_struct.reject { |k, _| k == :headers }
    end
  end
end
