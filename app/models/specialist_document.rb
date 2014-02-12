class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTRIBUTES = [:id, :title, :summary, :body, :state]

  def initialize(attributes)
    attributes ||= {}

    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  attr_accessor *ATTRIBUTES

  def slug
    "cma-cases/#{slug_from_title}"
  end

  def published?
    state == 'published'
  end

  def valid?
    true
  end

  def errors
    Hash.new({})
  end

  def persisted?
    false
  end

protected

  def slug_from_title
    title.downcase.gsub(/\W/, '-')
  end
end
