require "services"

# Publish a draft document. Also sends out emails.
class DocumentPublisher
  def self.publish(document)
    if document.first_draft?
      document.change_note = "First published."
      document.update_type = "major"
      document.save
    end
    Services.publishing_api.publish(document.content_id, nil, locale: document.locale)
    published_document = document.class.find(document.content_id, document.locale)

    if document.send_email_on_publish?
      # We don't have `public_updated_at` until the document is published, so we
      # get it from the publishing-api and manually set it on the orignal document
      # to preserve fields like `urgent` that are lost on publish.
      # This special case will go away once specialist-publisher starts using the
      # normal email-alert-service path for sending email alerts.
      document_with_public_updated_at = document
      document_with_public_updated_at.public_updated_at = published_document.public_updated_at
      EmailAlertApiWorker.perform_async(EmailAlertPresenter.new(document_with_public_updated_at).to_json.deep_stringify_keys)
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
