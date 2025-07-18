module PublishingApiHelpers
  def write_payload(document)
    copy = FactoryBot.create(document["document_type"], document)
    copy.delete("content_id")
    copy.delete("last_edited_at")
    copy.delete("publication_state")
    copy.delete("first_published_at")
    copy.delete("public_updated_at")
    copy.delete("state_history")
    copy
  end

  def assert_no_publishing_api_put_content(content_id)
    assert_publishing_api_put_content(content_id, nil, 0)
  end

  def update_govspeak_body_in_payload(document, attachments)
    mapped_attachments = attachments.map { |a| Attachment.new(a) }
    doc = instance_double(
      Document,
      attachments: mapped_attachments,
      body: document["details"]["body"][0]["content"],
    )
    updated_body_content = GovspeakBodyPresenter.present(doc)
    document["details"]["body"][0]["content"] = updated_body_content
  end

  # NOTE: we do this manually because the stub_publishing_api_has_content test helper
  # is too restrictive and we can't properly control pagination
  def publishing_api_paginates_content(content_items, per_page, document_klass, search_query: nil)
    total_pages = content_items.length / per_page
    total_pages += 1 unless content_items.length.remainder(per_page).zero?
    if total_pages.zero?
      publishing_api_has_no_content(document_klass, search_query)
    else
      content_items.each_slice(per_page).with_index.map do |page_items, index|
        body = {
          results: page_items,
          total: content_items.length,
          pages: total_pages,
          current_page: index + 1,
        }
        query_params = {
          page: (index + 1).to_s,
          document_type: document_klass.document_type,
        }
        query_params[:q] = search_query if search_query.present?

        stub_request(:get, "#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content")
          .with(query: hash_including(query_params))
          .to_return(status: 200, body: body.to_json, headers: {})
      end
    end
  end
end

RSpec.configuration.include PublishingApiHelpers
