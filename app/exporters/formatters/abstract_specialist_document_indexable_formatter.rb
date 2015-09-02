require "formatters/abstract_indexable_formatter"

class AbstractSpecialistDocumentIndexableFormatter < AbstractIndexableFormatter

private
  def expand_value(key)
    schema = SpecialistPublisherWiring.get("#{type}_finder_schema".to_sym)
    value = entity.send(key)
    schema.humanized_facet_value(key, value)
  end

  def public_timestamp
    entity.public_updated_at || entity.updated_at
  end
end
