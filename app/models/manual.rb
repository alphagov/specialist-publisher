class Manual
  attr_reader :id, :title, :summary, :organisation_slug, :updated_at

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @title = attributes.fetch(:title)
    @summary = attributes.fetch(:summary)
    @organisation_slug = attributes.fetch(:organisation_slug)
    @updated_at = attributes.fetch(:updated_at)
  end

  def to_param
    id
  end
end
