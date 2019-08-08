class PublishWorker
  include Sidekiq::Worker

  def perform(content_id)
    document = Document.find(content_id)

    unless safe_to_publish?(document)
      print_limitations_of_publishing(document)
      return
    end

    if document.publication_state == "draft"
      # bulk_published means that specialist-frontend won't render the publish
      # in this instance (https://github.com/alphagov/specialist-publisher/blob/44b082a2f3a91f1eb4fb5e1a9c65b0d9be1449eb/app/models/dfid_research_output.rb#L23-L26)
      document.bulk_published = true
      document.publish
    end
  end

private

  def safe_to_publish?(document)
    document.publication_state == "draft"
  end

  def print_limitations_of_publishing(document)
    content_id = document.content_id
    state = document.publication_state

    message = "Skipped publishing document with content_id #{content_id}"
    message += " because it has a state of '#{state}'."

    puts message
  end
end
