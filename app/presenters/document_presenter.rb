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
      document_type: document.document_type,
      change_note: document.change_note,
      schema_name: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      locale: "en",
      phase: document.phase,
      details: details,
      routes: [
        {
          path: document.base_path,
          type: "exact",
        }
      ],
      redirects: [],
      update_type: document.update_type,
    }.compact
  end

private

  attr_reader :document

  def details
    {
      body: GovspeakPresenter.present(@document),
      metadata: metadata,
      max_cache_time: 10,
      temporary_update_type: document.temporary_update_type,
    }.tap do |details_hash|
      details_hash[:attachments] = attachments if document.attachments.any?
      details_hash[:headers] = headers if !headers.empty?
    end
  end

  def headers
    headers = Govspeak::Document.new(document.body).structured_headers
    remove_empty_headers(headers.map(&:to_h))
  end

  def remove_empty_headers(headers)
    headers.each do |header|
      header.delete_if { |k, v| k == :headers && v.empty? }
      remove_empty_headers(header[:headers]) if header.has_key?(:headers)
    end
  end

  def attachments
    document.attachments.map { |attachment| AttachmentPresenter.new(attachment).to_json }
  end

  def metadata
    fields = document.format_specific_fields
    metadata = fields.each_with_object({}) do |field, hash|
      hash[field] = document.public_send(field)
    end

    metadata.merge!(
      bulk_published: document.bulk_published,
    )

    metadata.reject { |_k, v| v.blank? }
  end
end
