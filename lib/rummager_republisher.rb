class RummagerRepublisher
  class << self
    def republish_all
      document_types.each do |document_type|
        pagination = publishing_api_pagination_for(document_type)

        if pagination[:total_results].zero?
          puts "skipping - could not find #{document_type}"
          next
        end

        puts "Schedulling rummager republishing for document_type: #{document_type}"

        current_page = pagination[:current_page]
        per_page = pagination[:request_per_page]

        while current_page <= pagination[:total_pages]
          puts "Page: #{current_page} of #{pagination[:total_pages]}"

          RummagerBulkRepublisherWorker.perform_async(
            document_type,
            current_page,
            per_page
          )

          current_page += 1
        end
      end
    end

  private

    def publishing_api_pagination_for(document_type)
      response = Services.publishing_api.get_content_items(
        document_type: document_type,
        fields: [:content_id]
      )

      total_pages = response["pages"].zero? ? 1 : response["pages"].to_f
      total_results = response["total"].to_f

      # for console output when running the rake task.
      puts "about to process #{total_results} results for #{document_type}."

      {
        total_results: response["total"].to_f,
        total_pages: response["pages"].to_f,
        current_page: response["current_page"],
        request_per_page: (total_results / total_pages).ceil
      }
    end

    def document_types
      Rails.application.eager_load!
      @document_types ||= Document.subclasses.map(&:document_type)
    end
  end
end
