class AbstractArtefactFormatter
  def initialize(entity)
    @entity = entity
  end

  def resource_id
    entity.id
  end

  def name
    entity.title
  end

  def slug
    entity.slug
  end

  def paths
    ["/#{slug}"]
  end

  def attributes
    {
      name: name,
      slug: slug,
      kind: kind,
      rendering_app: rendering_app,
      paths: paths,
      state: state,
    }
  end

  def state
    raise NotImplementedError
  end

  def kind
    raise NotImplementedError
  end

  def rendering_app
    raise NotImplementedError
  end

  private

  attr_reader :entity

  def state_mapping
    {
      "published"   => "live",
      "draft"       => "draft",
      "withdrawn"   => "archived",
    }
  end
end
