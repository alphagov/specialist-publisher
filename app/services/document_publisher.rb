require "services"

# Publish a draft document. Also sends out emails.
class DocumentPublisher
  def self.publish(document)
    if document.first_draft?
      document.change_note = "First published."
      document.update_type = "major"
    end
    document.public_updated_at = Time.zone.now.strftime("%Y-%m-%dT%H:%M:%S%:z")
    document.save

    Services.publishing_api.publish(document.content_id, nil, locale: document.locale)

    if document.send_email_on_publish?
      # Sanitize the arguments to ensure they are native JSON types
      email_alert_arguments = EmailAlertPresenter.new(document).to_json.deep_stringify_keys
      json_safe_arguments = JSON.parse(JSON.dump(email_alert_arguments))

      EmailAlertApiWorker.perform_async(json_safe_arguments)
    end

    if previously_unpublished?(document)
      AttachmentRestoreWorker.perform_async(document.content_id, document.locale)
    end
  end

  def self.previously_unpublished?(document)
    ordered_states = document.state_history.sort.to_h.values
    ordered_states.last(2) == %w[unpublished draft]
  end
end
