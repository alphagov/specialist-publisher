module PublishingApiHelpers
  def write_payload(document)
    document.delete("updated_at")
    document.delete("publication_state")
    document.delete("first_published_at")
    document.delete("public_updated_at")
    document
  end

  def saved_for_the_first_time(document, at_time: Time.now.to_datetime.rfc3339)
    document.deep_merge(
      "details" => {
        "change_history" => [
          {
            "public_timestamp" => at_time,
            "note" => "First published.",
          }
        ]
      }
    )
  end
end

RSpec.configuration.include PublishingApiHelpers
