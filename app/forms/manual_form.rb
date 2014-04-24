class ManualForm
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :title, :summary

  def self.model_name
    ActiveModel::Name.new(self, nil, "Manual")
  end

  def persisted?
    false
  end
end
