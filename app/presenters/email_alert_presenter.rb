class EmailAlertPresenter
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def to_json(*_args)
    {
      title:,
      description: summary,
      change_note:,
      subject:,
      tags:,
      links:,
      urgent:,
      document_type: document.document_type,
      email_document_supertype: "other",
      government_document_supertype: "other",
      content_id:,
      public_updated_at:,
      publishing_app: "specialist-publisher",
      base_path:,
      priority:,
    }.merge(extra_options)
  end

  delegate :content_id, to: :document

private

  # The tags are sent to email-alert-api and matched against subscriberlists.
  def tags
    metadata_tags = document.format_specific_metadata.reject do |k, v|
      # remove the lengthy indexable text content present in many document types
      k == :hidden_indexable_content || v.blank?
    end

    { format: document.format }.merge(metadata_tags)
  end

  def links
    DocumentLinksPresenter.new(document).to_json[:links]
  end

  def title
    redrafted? ? "#{document.title} updated" : document.title
  end

  def summary
    document.summary
  end

  def change_note
    document.change_note
  end

  def subject
    title
  end

  def urgent
    document.urgent
  end

  def priority
    urgent ? "high" : "normal"
  end

  def footnote
    document.email_footnote
  end

  def public_updated_at
    document.public_updated_at
  end

  def base_path
    document.base_path
  end

  def updated_or_published
    redrafted? ? "updated" : "published"
  end

  def redrafted?
    document.draft? && !document.first_draft?
  end

  def extra_options
    {
      footnote:,
    }.reject { |_k, v| v.nil? }
  end
end
