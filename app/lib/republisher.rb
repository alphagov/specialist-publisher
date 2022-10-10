require "services"

module Republisher
module_function

  def republish_all
    all_content_ids_and_locales.each do |content_id, locale|
      RepublishWorker.perform_async(content_id, locale)
    end
  end

  def republish_document_type(document_type)
    content_id_and_locale_pairs_for_document_type(
      document_type,
    ).each do |content_id, locale|
      RepublishWorker.perform_async(content_id, locale)
    end
  end

  def republish_one(content_id, locale)
    RepublishWorker.new.perform(content_id, locale)
  end

  def republish_many(content_ids_and_locales)
    content_ids_and_locales.each do |content_id, locale|
      RepublishWorker.perform_async(content_id, locale)
    end
  end

  def all_content_ids_and_locales
    document_types.flat_map do |t|
      content_id_and_locale_pairs_for_document_type(t)
    end
  end

  def content_id_and_locale_pairs_for_document_type(document_type)
    unless document_types.include?(document_type)
      raise ArgumentError, "Unknown document_type: '#{document_type}'"
    end

    Services.with_timeout(30) do
      Services.publishing_api.get_content_items(
        document_type:,
        fields: %i[content_id locale],
        per_page: 999_999,
        order: "updated_at",
      )["results"].map { |r| [r["content_id"], r["locale"]] }
    end
  end

  def document_types
    @document_types ||= all_document_types
  end

  def all_document_types
    Rails.application.eager_load!
    Document.subclasses.map(&:document_type)
  end
end
