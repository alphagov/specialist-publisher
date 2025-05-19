require "services"

class Publisher
  def self.publish_all(types: nil, disable_email_alert: false)
    new(types).publish_all(disable_email_alert)
  end

  def publish_all(disable_email_alert)
    types.each do |document_type|
      publish_document_type(document_type, disable_email_alert)
    end
  end

private

  attr_reader :types

  def initialize(types)
    @types = types.presence || document_types
  end

  def publish_document_type(document_type, disable_email_alert)
    content_id_and_locale_pairs_for_document_type(
      document_type,
    ).each do |content_id, locale|
      document = Document.find(content_id, locale)
      document.disable_email_alert = true if disable_email_alert

      unless Services.with_timeout(30) { document.publish }
        Rails.logger.warn "Cannot publish document: #{content_id}:#{locale}"
      end
    end
  end

  def content_id_and_locale_pairs_for_document_type(document_type)
    unless document_types.include?(document_type)
      raise ArgumentError, "Unknown document_type: '#{document_type}'"
    end

    Services.with_timeout(30) do
      Services.publishing_api.get_content_items(
        document_type:,
        publication_state: "draft",
        fields: %i[content_id locale],
        per_page: 999_999,
        order: "updated_at",
      )["results"].map { |r| r.values_at("content_id", "locale") }
    end
  end

  def document_types
    Rails.application.eager_load!
    @document_types ||= all_document_types
  end

  def all_document_types
    Rails.application.eager_load!
    DocumentTypeMapper.all_document_types
  end
end
