require "fetchable"

class SpecialistDocumentRepository
  include Fetchable

  NotFoundError = Module.new

  def fetch(*args, &block)
    super
  rescue KeyError => e
    raise e.extend(NotFoundError)
  end

  def initialize(dependencies)
    @specialist_document_editions = dependencies.fetch(:specialist_document_editions)
    @document_factory = dependencies.fetch(:document_factory)
  end

  def all(limit = -1, offset = 0)
    lower_bound = offset
    upper_bound = limit < 0 ? limit : offset + limit - 1

    all_document_ids[lower_bound..upper_bound]
      .map { |id| self[id] }
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

  def count
    specialist_document_editions.count
  end

private
  attr_reader(
    :specialist_document_editions,
    :document_factory,
  )

  # TODO Add a method on SpecialistDocumentEdition to handle this
  def all_document_ids
    specialist_document_editions
      .all
      .only(:document_id, :updated_at)
      .sort { |a, b| b.updated_at <=> a.updated_at }
      .map(&:document_id)
      .uniq
  end
end
