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
    # It is actually only necessary to save the latest edition, however, I
    # think it's safer to save latest two as both are exposed to the and have
    # potential to change. This extra write may save a potential future
    # headache.
    document.editions.last(2).each(&:save!)

    self
  end

private

  attr_reader(
    :panopticon_mappings,
    :specialist_document_editions,
    :document_factory,
  )

end
