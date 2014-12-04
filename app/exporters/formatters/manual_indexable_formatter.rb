require "formatters/abstract_indexable_formatter"

class ManualIndexableFormatter < AbstractIndexableFormatter
  def type
    "manual"
  end

private
  def indexable_content
    entity.summary # Manuals don't have a body
  end

  def organisation_slugs
    [entity.organisation_slug]
  end
end
