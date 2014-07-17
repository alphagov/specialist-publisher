require "forwardable"

class ManualDocumentViewAdapter < SimpleDelegator
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def initialize(manual, document)
    @manual = manual
    @document = document
    super(document)
  end

  def persisted?
    document.updated_at || document.published?
  end

  def minor_update
    document.draft? ? document.minor_update : false
  end

  def change_note
    document.draft? ? document.change_note : ""
  end

  def to_param
    document.id
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Document")
  end

private
  attr_reader :manual, :document
end
