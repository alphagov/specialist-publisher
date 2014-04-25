class ManualForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :title, :summary

  def self.model_name
    ActiveModel::Name.new(self, nil, "Manual")
  end

  def id
    @id ||= SecureRandom.uuid
  end

  def update(attributes)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def to_param
    id
  end
end
