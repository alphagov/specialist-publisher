require "specialist_publisher_wiring"

class RummagerIndexer
  def add(document)
    api.add_document(document.type, document.id, document.indexable_attributes)
  end

  def delete(document)
    api.delete_document(document.type, document.id)
  end

private
  def api
    SpecialistPublisherWiring.get(:rummager_api)
  end
end
