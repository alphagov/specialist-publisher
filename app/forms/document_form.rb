require "forwardable"

class DocumentForm < SimpleDelegator
  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion

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

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

private

  attr_reader :document

  def delegate_if_document_exists(attribute_name)
    document && document.public_send(attribute_name)
  end

  def finder_schema
    raise NotImplementedError
  end
end
