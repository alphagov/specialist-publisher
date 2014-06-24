require "forwardable"

class DocumentForm < SimpleDelegator

  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "SpecialistDocument")
  end

  def initialize(document)
    @document = document
    super(document)
  end

  def attachments
    document && document.attachments || []
  end

  def persisted?
    document && document.updated_at
  end

  def to_param
    document.id
  end

private

  attr_reader :document

  def delegate_if_document_exists(attribute_name)
    document && document.public_send(attribute_name)
  end
end
