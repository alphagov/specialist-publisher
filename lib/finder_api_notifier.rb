class FinderAPINotifier
  def initialize(api_client, markdown_attachment_renderer)
    @api_client = api_client
    @markdown_attachment_renderer = markdown_attachment_renderer
  end

  def call(document)
    rendered_document = markdown_attachment_renderer.call(document)

    api_client.notify_of_publication(
      rendered_document.slug,
      filtered_attributes(rendered_document),
    )
  end

  private

  attr_reader :api_client, :markdown_attachment_renderer

  def filtered_attributes(rendered_document)
    rendered_document.attributes.reduce({}) { |attributes, (k, v)|
      attributes.merge(
        k => v.presence,
      )
    }
  end
end
