class Manual
  attr_reader :id, :title, :summary, :updated_at

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @title = attributes.fetch(:title)
    @summary = attributes.fetch(:summary)
    @updated_at = attributes.fetch(:updated_at)
  end

  def to_param
    id
  end
end
