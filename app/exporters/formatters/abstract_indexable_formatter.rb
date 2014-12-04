class AbstractIndexableFormatter
  def initialize(entity)
    @entity = entity
  end

  def type
    raise NotImplementedError
  end

  def id
    link
  end

  def indexable_attributes
    base_attributes.merge(extra_attributes)
  end

private
  attr_reader :entity

  def base_attributes
    {
      title: title,
      description: description,
      link: link,
      indexable_content: indexable_content,
      organisations: organisation_slugs,
      last_update: last_update,
    }
  end

  def extra_attributes
    {}
  end

  def title
    entity.title
  end

  def description
    entity.summary
  end

  def link
    entity.slug
  end

  def indexable_content
    entity.body
  end

  def last_update
    entity.updated_at
  end

  def organisation_slugs
    raise NotImplementedError
  end
end
