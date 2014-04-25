class Manual
  attr_reader :id, :title, :summary

  def initialize(attributes)
    @id = attributes.fetch(:id)
    @title = attributes.fetch(:title)
    @summary = attributes.fetch(:summary)
  end

  def to_param
    id
  end
end
