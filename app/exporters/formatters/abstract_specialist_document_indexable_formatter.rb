require "formatters/abstract_indexable_formatter"

class AbstractSpecialistDocumentIndexableFormatter < AbstractIndexableFormatter

private
  def last_update
    entity.public_updated_at || entity.updated_at
  end
end
