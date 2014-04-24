class PublishedDocumentRenderer
  SpecialistPublisherWiring.inject_into(self)

  def rerender!
    specialist_document_repository
      .all
      .lazy
      .select(&:published?)
      .map(&:published_version)
      .each do |published_document|
        specialist_document_content_api_exporter.call(published_document)
      end
  end
end

