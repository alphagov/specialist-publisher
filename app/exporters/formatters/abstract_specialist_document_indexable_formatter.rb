require "formatters/abstract_indexable_formatter"

class AbstractSpecialistDocumentIndexableFormatter < AbstractIndexableFormatter

private
  def last_update
    entity.minor_update? ? entity.last_published_at : entity.updated_at
  end
end
