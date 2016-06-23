require "services"

class RepublishWorker
  include Sidekiq::Worker

  def perform(content_id, _ = nil)
    document = Document.find(content_id)
    document.update_type = "republish"

    unless safe_to_republish?(document)
      print_limitations_of_republishing(document)
      return
    end

    publishing_api_put_content(document)
    publishing_api_patch_links(document)

    if document.publication_state == "live"
      publishing_api_publish(document)
      rummager_add_document(document)
    end
  end

private

  def safe_to_republish?(document)
    %w(draft redrafted live).include?(document.publication_state)
  end

  def print_limitations_of_republishing(document)
    content_id = document.content_id
    state = document.publication_state

    message = "Skipped republishing document with content_id #{content_id}"
    message += " because it has a state of '#{state}'. Currently, there is"
    message += " no way to safely republish the document that is supported by"
    message += " the platform."

    puts message
  end

  def publishing_api_put_content(document)
    payload = DocumentPresenter.new(document).to_json
    Services.publishing_api.put_content(document.content_id, payload)
  end

  def publishing_api_patch_links(document)
    payload = DocumentLinksPresenter.new(document).to_json
    Services.publishing_api.patch_links(document.content_id, payload)
  end

  def publishing_api_publish(document)
    Services.publishing_api.publish(document.content_id, "republish")
  end

  def rummager_add_document(document)
    payload = SearchPresenter.new(document).to_json
    Services.rummager.add_document(document.document_type, document.base_path, payload)
  end
end
