class FinderAPI
  def initialize(http_client, plek)
    finder_api_host = plek.find("finder-api")
    @http_client = http_client.new(url: finder_api_host)
  end

  def notify_of_publication(finder_slug, document)
    @http_client.post("/finders/#{finder_slug}", document.to_json)
  end
end
