require "formatters/abstract_indexable_formatter"

class AbstractSpecialistDocumentIndexableFormatter < AbstractIndexableFormatter

private
  def expand_value(key)
    FinderSchema.humanized_facet_name(key, entity, type)
  end

  def public_timestamp
    entity.public_updated_at || entity.updated_at
  end
end
