class Manual
  attr_reader :id, :title, :summary, :organisation_slug, :updated_at

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @updated_at = attributes.fetch(:updated_at)

    update(attributes)
  end

  def to_param
    id
  end

  def update(attributes)
    @title = attributes.fetch(:title)
    @summary = attributes.fetch(:summary)
    @organisation_slug = attributes.fetch(:organisation_slug)

    self
  end
end
