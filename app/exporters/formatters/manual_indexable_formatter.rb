require "formatters/abstract_indexable_formatter"

class ManualIndexableFormatter < AbstractIndexableFormatter
  def type
    "manual"
  end

private
  def extra_attributes
    {
      specialist_sectors: specialist_sectors
    }
  end

  def indexable_content
    entity.summary # Manuals don't have a body
  end

  def organisation_slugs
    [entity.organisation_slug]
  end

  def specialist_sectors
    if entity.tags.present?
      entity.tags.select { |t| t[:type] == "specialist_sector" }.map { |t| t[:slug] }
    else
      []
    end
  end
end
