require "services"

class RepublishService
  def call(content_id, locale, &put_content_block)
    document = Document.find(content_id, locale)

    case document.publication_state
    when "published"
      document.update_type = "republish"

      publishing_api_put_content(document, &put_content_block)
      publishing_api_patch_links(document)
      publishing_api_publish(document)
    when "draft"
      published_edition_version_number = document.state_history.key("published")

      publishing_api_patch_links(document)

      if published_edition_version_number.present?
        published_document = Document.find(
          content_id,
          locale,
          version: published_edition_version_number,
        )
        published_document.update_type = "republish"

        publishing_api_put_content(published_document, &put_content_block)
        publishing_api_publish(published_document)
      end

      publishing_api_put_content(document, &put_content_block)
    else
      print_limitations_of_republishing(document)
    end
  end

private

  def print_limitations_of_republishing(document)
    content_id = document.content_id
    state = document.publication_state

    message = "Skipped republishing document with content_id #{content_id}"
    message += " because it has a state of '#{state}'. Currently, there is"
    message += " no way to safely republish the document that is supported by"
    message += " the platform."

    logger.warn message
  end

  def publishing_api_put_content(document, &block)
    payload = DocumentPresenter.new(document).to_json
    payload = payload.tap { |x| block.call(x) } if block
    payload.merge!(bulk_publishing: true)
    payload.merge!(last_edited_at: document.last_edited_at)
    Services.publishing_api.put_content(document.content_id, payload)
  end

  def publishing_api_patch_links(document)
    payload = DocumentLinksPresenter.new(document).to_json
    payload.merge!(bulk_publishing: true)
    Services.publishing_api.patch_links(document.content_id, payload)
  end

  def publishing_api_publish(document)
    Services.publishing_api.publish(document.content_id, "republish")
  end
end
