module PublishingApiHelpers
  def write_payload(document)
    document.delete("updated_at")
    document.delete("publication_state")
    document
  end

  def saved_for_the_first_time(document)
    timestamp = Time.now.to_datetime.rfc3339
    document.deep_merge(
      "public_updated_at" => timestamp,
      "details" => {
        "change_history" => [
          {
            "public_timestamp" => timestamp,
            "note" => "First published.",
          }
        ]
      }
    )
  end
end

RSpec.configuration.include PublishingApiHelpers
