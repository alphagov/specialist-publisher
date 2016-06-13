module PublishingApiHelpers
  def write_payload(document)
    document.delete("updated_at")
    document.delete("publication_state")
    document.delete("first_published_at")
    document.delete("public_updated_at")
    document
  end
end

RSpec.configuration.include PublishingApiHelpers
