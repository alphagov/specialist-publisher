module OpsTasks
module_function

  def discard(content_id)
    Document.find(content_id).discard
  end

  def email(content_id)
    document = Document.find(content_id)
    payload = EmailAlertPresenter.new(document).to_json

    GdsApi.email_alert_api.create_content_change(payload)
  end

  def set_public_updated_at(content_id, timestamp)
    timestamp = if timestamp == "now"
                  Time.zone.now
                else
                  Time.zone.parse(timestamp)
                end

    document = Document.find(content_id)
    document.update_type = "republish"

    state = document.publication_state
    raise_helpful_error(state) unless state == "published"

    payload = DocumentPresenter.new(document).to_json
    payload["public_updated_at"] = timestamp

    Services.publishing_api.put_content(content_id, payload)
    Services.publishing_api.publish(content_id, "republish")
  end

  def raise_helpful_error(state)
    message = "That document has a '#{state}' state"
    message += " and cannot be updated. You can either:"
    message += "\n\n1) Publish the document then run this script again"
    message += "\n2) Discard the existing draft then run this script again"
    message += "\n3) Edit the public_updated_at manually in Publishing API"

    raise message
  end
end
