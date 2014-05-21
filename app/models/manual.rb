class Manual
  attr_reader(
    :id,
    :title,
    :summary,
    :organisation_slug,
    :state,
    :updated_at,
  )

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @updated_at = attributes.fetch(:updated_at, nil)

    update(attributes)
  end

  def to_param
    id
  end

  def update(attributes)
    @title = attributes.fetch(:title, nil)
    @summary = attributes.fetch(:summary, nil)
    @organisation_slug = attributes.fetch(:organisation_slug, nil)
    @state = attributes.fetch(:state, nil)

    self
  end

  def publish(&block)
    if @state == "draft"
      @state = "published"
      block.call if block
    end

    self
  end
end
