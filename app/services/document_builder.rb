# Build a `Document` from the publishing-api payload
class DocumentBuilder
  def self.build(klass, payload)
    document = klass.new(
      base_path: payload["base_path"],
      content_id: payload["content_id"],
      locale: payload["locale"],
      title: payload["title"],
      summary: payload["description"],
      body: extract_body_from_payload(payload),
      publication_state: payload["publication_state"],
      state_history: payload["state_history"],
      public_updated_at: payload["public_updated_at"],
      last_edited_at: payload["last_edited_at"],
      first_published_at: payload["first_published_at"],
      bulk_published: payload["details"]["metadata"]["bulk_published"],
      previous_version: payload["previous_version"],
      temporary_update_type: payload["details"]["temporary_update_type"],
      warnings: payload["warnings"] || {},
      internal_notes: extract_unpublishing_explanation(payload),
    )

    set_update_type(document, payload)

    if document.has_organisations?
      primary_organisation_ary = payload["links"]["primary_publishing_organisation"] || []
      document.primary_publishing_organisation = primary_organisation_ary.first
      document.organisations = (payload["links"]["organisations"] || []) - primary_organisation_ary
    end

    document.attachments = Attachment.all_from_publishing_api(payload)

    document.format_specific_fields.each do |field|
      document.public_send(:"#{field}=", payload["details"]["metadata"][field.to_s])
    end

    document.body = SpecialistPublisherBodyPresenter.present(document)
    document
  end

  def self.extract_unpublishing_explanation(payload)
    unpublishing = payload["unpublishing"]
    unpublishing["explanation"] if unpublishing
  end

  def self.extract_body_from_payload(payload)
    body_attribute = payload.fetch("details").fetch("body")

    case body_attribute
    when Array
      govspeak_body = body_attribute.detect do |body_hash|
        body_hash["content_type"] == "text/govspeak"
      end
      govspeak_body["content"]
    when String
      body_attribute
    end
  end

  def self.set_update_type(document, payload)
    if document.temporary_update_type?
      document.update_type = nil
      document.temporary_update_type = false
    elsif document.published? || document.unpublished?
      document.update_type = nil
    elsif document.first_draft?
      document.update_type = "major"
    else
      document.update_type = payload["update_type"]
      document.change_note = payload["change_note"]
    end
  end
end
