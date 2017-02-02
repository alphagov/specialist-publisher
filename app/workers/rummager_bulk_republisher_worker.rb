class RummagerBulkRepublisherWorker
  include Sidekiq::Worker

  def perform(document_type, page, per_page)
    Services.publishing_api.client.options[:timeout] = 30

    results = Services.publishing_api.get_content_items(
      document_type: document_type,
      fields: [:content_id],
      per_page: per_page,
      page: page,
    )["results"]

    puts "found #{results.size} results for document_type: #{document_type}"

    content_ids = results.map { |result| result["content_id"] }

    content_ids.each do |content_id|
      document = Document.find(content_id)
      payload = SearchPresenter.new(document).to_json

      puts "sending content_id: #{content_id} to rummager."
      RummagerWorker.perform_async(
        document.document_type,
        document.base_path,
        payload
      )
    end
  end
end
