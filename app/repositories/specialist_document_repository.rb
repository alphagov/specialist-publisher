require "gds_api/panopticon"
require "fetchable"

class SpecialistDocumentRepository
  include Fetchable

  def initialize(panopticon_mappings,
    specialist_document_editions,
    specialist_document_factory)
    @panopticon_mappings = panopticon_mappings
    @specialist_document_editions = specialist_document_editions
    @document_factory = specialist_document_factory
  end

  def all
    # TODO: add a method on PanopticonMapping to handle this
    document_ids = panopticon_mappings.all_document_ids
    documents = document_ids.map { |id| self[id] }.to_a.compact

    documents.sort_by(&:updated_at).reverse
  end

  def [](id)
    # TODO: add a method on SpecialistDocumentEdition to handle this
    editions = specialist_document_editions
      .where(document_id: id)
      .order_by([:version_number, :desc])
      .limit(2)
      .to_a
      .reverse

    if editions.empty?
      nil
    else
      document_factory.call(id, editions)
    end
  end

  def slug_unique?(document)
    # TODO: push this method down into persistence layer
    editions_with_slug = specialist_document_editions.where(
      :slug => document.slug,
      :document_id.ne => document.id,
    ).empty?
  end

  def store(document)
    # This actually isn't necessary because only the latest edition ever changes
    # I think it's safer to perform the save anyway as there is potential for
    # the previous editions to change
    document.editions.last(2).each(&:save!)

    self
  end

  NotFound = Class.new(StandardError)

  class InvalidDocumentError < StandardError
    def initialize(message, document)
      super(message)
      @document = document
    end

    attr_reader :document
  end

private

  attr_reader(
    :panopticon_mappings,
    :specialist_document_editions,
    :document_factory,
  )

end
