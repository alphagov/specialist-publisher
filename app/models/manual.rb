class Manual
  attr_reader(
    :id,
    :slug,
    :title,
    :summary,
    :body,
    :organisation_slug,
    :state,
    :version_number,
    :updated_at,
    :tags,
  )

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @updated_at = attributes.fetch(:updated_at, nil)
    @version_number = attributes.fetch(:version_number, 0)

    update(attributes)
  end

  def to_param
    id
  end

  def attributes
    {
      id: id,
      slug: slug,
      title: title,
      summary: summary,
      body: body,
      organisation_slug: organisation_slug,
      state: state,
      version_number: version_number,
      updated_at: updated_at,
      tags: tags,
    }
  end

  def update(attributes)
    @slug = attributes.fetch(:slug) { slug }
    @title = attributes.fetch(:title) { title }
    @summary = attributes.fetch(:summary) { summary }
    @body = attributes.fetch(:body) { body }
    @organisation_slug = attributes.fetch(:organisation_slug) { organisation_slug }
    @state = attributes.fetch(:state) { state }
    @tags = attributes.fetch(:tags) { tags }

    self
  end

  def publish(&block)
    @state = "published"
    block.call if block

    self
  end

  def draft?
    state == "draft"
  end

  def publication_state
    state
  end

  def published?
    state == "published"
  end

  def withdraw
    @state = "withdrawn" if state == "published"

    self
  end

  def withdrawn?
    state == "withdrawn"
  end
end
