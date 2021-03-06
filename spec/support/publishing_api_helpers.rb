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
end

RSpec.configuration.include PublishingApiHelpers
