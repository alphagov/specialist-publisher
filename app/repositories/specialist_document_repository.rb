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
    @document_type = dependencies.fetch(:document_type)
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

  def search(query)
    conditions = search_conditions(query)

    all_document_ids_scoped(conditions)
      .map { |id| fetch(id)  }
  end

  def slug_unique?(document)
    # TODO: push this method down into persistence layer
    if document.draft?
      specialist_document_editions.where(
        :slug => document.slug,
        :document_id.ne => document.id,
        :state => "published"
      ).empty?
    else
      true
    end
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
    specialist_document_editions.distinct(:document_id).count
  end

private
  attr_reader(
    :document_type,
    :document_factory,
  )

  def search_conditions(query)
    matcher = /#{query}/i
    searchable_attributes.map { |attr|
      {attr => matcher}
    }
  end

  def searchable_attributes
    [
      :title,
      :slug,
    ]
  end

  def all_document_ids_scoped(conditions)
    only_document_ids_for(
      specialist_document_editions
        .any_of(conditions)
    )
  end

  def only_document_ids_for(collection)
    collection.all
      .order_by(updated_at: "desc")
      .only(:document_id, :updated_at)
      .map(&:document_id)
      .uniq
  end

  # TODO Add a method on SpecialistDocumentEdition to handle this
  def all_document_ids
    only_document_ids_for(
      specialist_document_editions
        .all
    )
  end

  def specialist_document_editions
    SpecialistDocumentEdition.where(document_type: document_type)
  end
end
