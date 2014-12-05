require "formatters/abstract_indexable_formatter"

class AbstractSpecialistDocumentIndexableFormatter < AbstractIndexableFormatter

private
  def last_update
    entity.previous_major_updated_at
  end
end
