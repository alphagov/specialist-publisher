require "gds_api/rummager"

class RummagerIndexer
  def add(document)
    api.add_document(document.type, document.id, document.indexable_attributes)
  end

  def delete(document)
    api.delete_document(document.type, document.id)
  end

private
  def api
    GdsApi::Rummager.new(Plek.new.find("search"))
  end
end
