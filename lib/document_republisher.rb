require "gds_api/exceptions"

class DocumentRepublisher
  class MultiplePublishedEditionsError < RuntimeError; end

  def initialize(repository_listeners_map)
    @repositories = repository_listeners_map
  end

  def republish!
    repositories.each do |repo, listeners|
      puts "= Republishing #{all_documents(repo).count} documents from: #{repo.inspect}"
      all_documents(repo).each do |document|
        republish(document, repo.send(:document_factory), listeners)
      end
    end
  end

private
  attr_reader :repositories

  def republish(document, document_factory, listeners)
    editions = document.editions.select { |e| e.published? }
    raise MultiplePublishedEditionsError if editions.size > 1
    puts "== Republishing document: '#{document.slug}' / '#{document.id}'"

    factoried_document = document_factory.call(editions.first.document_id, editions)
    listeners.each { |o| o.call(factoried_document) }
  rescue GdsApi::HTTPErrorResponse, MultiplePublishedEditionsError
    puts "## ERRORED Republishing: '#{document.slug}' / '#{document.id}'"
    puts "=== message: #{$!.message}"
  end

  def all_documents(repo)
    @documents ||= {}
    @documents[repo] ||= repo.all.lazy.select(&:published?)
  end
end
