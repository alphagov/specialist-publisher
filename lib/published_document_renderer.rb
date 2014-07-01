class PublishedDocumentRenderer
  SpecialistPublisherWiring.inject_into(self)
  class MultiplePublishedEditionsError < RuntimeError; end

  def rerender!
    repositories.each do |repo, listeners|
      docs = repo.all.lazy.select(&:published?)
      puts "= Republishing #{docs.count} documents from: #{repo.inspect}"
      docs.each do |document|
        republish(document, repo.send(:document_factory), listeners)
      end
    end
  end

private
  def republish(document, document_factory, listeners)
    editions = document.editions.select { |e| e.published? }
    raise MultiplePublishedEditionsError if editions.size > 1
    puts "== Republishing document: '#{document.slug}' / '#{document.id}'"

    factoried_document = document_factory.call(editions.first.document_id, editions)
    factoried_document.publish!
    listeners.each { |o| o.call(factoried_document) }
  rescue GdsApi::HTTPErrorResponse, MultiplePublishedEditionsError
    puts "## ERRORED Republishing: '#{document.slug}' / '#{document.id}'"
    puts "=== message: #{$!.message}"
  end

  # Commented out lines show how we *want* to do this for aaib reports and
  # manuals. Aaib reports should work (but is untested), manuals is awaiting a
  # sane method of accessing all of them through a repository.
  def repositories
    [
      [specialist_document_repository, observers.document_publication],
      #[aaib_report_repository, observers.document_publication],
      #[manuals_repository, observers.manual_publication],
    ]
  end
end
