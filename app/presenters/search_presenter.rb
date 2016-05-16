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
      public_timestamp: document.public_updated_at.to_datetime.rfc3339,
    }.merge(document.format_specific_metadata).reject { |_k, v| v.blank? }
  end

  def indexable_content
    Govspeak::Document.new(document.body).to_text
  end

private

  attr_reader :document
end
