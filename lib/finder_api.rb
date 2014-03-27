class FinderAPI
  def initialize(http_client, plek)
    finder_api_host = plek.find("finder-api")
    @http_client = http_client.new(url: finder_api_host)
  end

  def notify_of_publication(slug, document_attributes)
    @http_client.put("/finders/#{slug}", document: document_attributes.to_json)
  end
end
