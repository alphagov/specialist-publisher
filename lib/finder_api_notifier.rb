class FinderAPINotifier
  def initialize(api_client, markdown_renderer)
    @api_client = api_client
    @markdown_renderer = markdown_renderer
  end

  def call(document)
    rendered_document = markdown_renderer.call(document)

    api_client.notify_of_publication(
      rendered_document.slug,
      rendered_document.attributes,
    )
  end

  private

  attr_reader :api_client, :markdown_renderer
end
