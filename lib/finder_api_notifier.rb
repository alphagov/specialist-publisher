class FinderAPINotifier
  def initialize(api_client, markdown_renderer)
    @api_client = api_client
    @markdown_renderer = markdown_renderer
  end

  def call(document)
    rendered_document = markdown_renderer.call(document)

    api_client.notify_of_publication(
      rendered_document.slug,
      filtered_attributes(rendered_document),
    )
  end

  private

  attr_reader :api_client, :markdown_renderer

  def filtered_attributes(rendered_document)
    rendered_document.attributes.reduce({}) { |attributes, (k, v)|
      attributes.merge(
        k => v.presence,
      )
    }
  end
end
