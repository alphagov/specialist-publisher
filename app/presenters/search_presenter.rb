class SearchPresenter
  delegate :title, to: :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      title: document.title,
      description: document.summary,
      link: document.base_path,
      indexable_content: indexable_content,
      public_timestamp: format_date(document.public_updated_at),
      first_published_at: format_date(document.first_published_at),
    }.merge(document.format_specific_metadata).reject { |_k, v| v.blank? }
  end

  def format_date(timestamp)
    raise ArgumentError, "Timestamp is blank" if timestamp.blank?
    timestamp.to_datetime.rfc3339
  end

  def indexable_content
    Govspeak::Document.new(document.body).to_text
  end

private

  attr_reader :document
end
