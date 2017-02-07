class SearchPresenter
  delegate :title, to: :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      title: document.title,
      content_id: document.content_id,
      content_store_document_type: document.document_type,
      description: document.summary,
      link: document.base_path,
      indexable_content: indexable_content,
      publishing_app: 'specialist-publisher',
      rendering_app: 'specialist-frontend',
      public_timestamp: format_date(document.public_updated_at),
      first_published_at: format_date(document.first_published_at),
    }.merge(document.format_specific_metadata).reject { |_k, v| v.blank? }
  end

  def format_date(timestamp)
    raise ArgumentError, "Timestamp is blank" if timestamp.blank?
    timestamp.to_datetime.rfc3339
  end

  def indexable_content
    hidden_content = defined?(document.hidden_indexable_content) ? " " + document.hidden_indexable_content : ""
    Govspeak::Document.new(document.body).to_text + hidden_content
  end

private

  attr_reader :document
end
