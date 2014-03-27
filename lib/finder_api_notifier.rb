class FinderAPINotifier
  def initialize(api_client)
    @api_client = api_client
  end

  def call(document)
    @api_client.notify_of_publication(document.slug, document.attributes)
  end
end
