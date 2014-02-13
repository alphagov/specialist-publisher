class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTRIBUTES = [:id, :title, :summary, :body, :updated_at]

  def initialize(attributes = nil)
    attributes ||= {}

    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end

    @errors = Hash.new({})
  end

  attr_accessor *ATTRIBUTES
  attr_accessor :errors

  def slug
    "cma-cases/#{slug_from_title}"
  end

  def valid?
    errors.empty?
  end

  def persisted?
    id.present?
  end

protected

  def slug_from_title
    title.downcase.gsub(/\W/, '-')
  end
end
