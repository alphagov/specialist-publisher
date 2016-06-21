module PublishingApiHelpers
  def write_payload(document)
    document.delete("last_edited_at")
    document.delete("publication_state")
    document.delete("first_published_at")
    document.delete("public_updated_at")
    document.delete("state_history")
    document
  end

  def assert_no_publishing_api_put_content(content_id)
    assert_publishing_api_put_content(content_id, nil, 0)
  end
end

RSpec.configuration.include PublishingApiHelpers
