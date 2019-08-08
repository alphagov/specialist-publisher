module Republisher
module_function

  def republish_all
    all_content_ids.each do |content_id|
      RepublishWorker.perform_async(content_id)
    end
  end

  def republish_document_type(document_type)
    content_ids_for_document_type(document_type).each do |content_id|
      RepublishWorker.perform_async(content_id)
    end
  end

  def republish_one(content_id)
    RepublishWorker.new.perform(content_id)
  end

  def republish_many(content_ids)
    content_ids.each do |content_id|
      RepublishWorker.perform_async(content_id)
    end
  end

  def all_content_ids
    document_types.flat_map { |t| content_ids_for_document_type(t) }
  end

  def content_ids_for_document_type(document_type)
    unless document_types.include?(document_type)
      raise ArgumentError, "Unknown document_type: '#{document_type}'"
    end

    with_timeout(30) do
      Services.publishing_api.get_content_items(
        document_type: document_type,
        fields: [:content_id],
        per_page: 999999,
      )["results"].map { |r| r["content_id"] }
    end
  end

  def document_types
    @document_types ||= all_document_types
  end

  def all_document_types
    Rails.application.eager_load!
    Document.subclasses.map(&:document_type)
  end

  def with_timeout(seconds)
    previous_timeout = Services.publishing_api.client.options[:timeout]

    Services.publishing_api.client.options[:timeout] = seconds
    result = yield
    Services.publishing_api.client.options[:timeout] = previous_timeout

    result
  end
end
