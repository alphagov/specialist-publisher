require "delegate"

class ManualViewAdapter < SimpleDelegator
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def initialize(manual)
    @manual = manual
    super(manual)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Manual")
  end

  def persisted?
    manual.updated_at.present?
  end

  def to_param
    id
  end

private
  attr_reader :manual
end
