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
      public_timestamp: public_timestamp,
    }
  end

  def extra_attributes
    raise NotImplementedError
  end

  def title
    entity.title
  end

  def description
    entity.summary
  end

  def link
    with_leading_slash(entity.slug)
  end

  def with_leading_slash(slug)
    slug.start_with?("/") ? slug : "/#{slug}"
  end

  def indexable_content
    entity.body
  end

  def public_timestamp
    entity.updated_at
  end

  def organisation_slugs
    raise NotImplementedError
  end
end
