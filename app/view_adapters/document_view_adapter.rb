require "forwardable"

class DocumentViewAdapter < SimpleDelegator
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
    document && document.persisted?
  end

  def to_param
    document.id
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  def humanized_attributes
    extra_fields.inject({}) do |attributes, (key, value)|
      humanized_name = finder_schema.humanized_facet_name(key) { key }
      humanized_value = finder_schema.humanized_facet_value(key, value) { value }

      attributes.merge(humanized_name => humanized_value)
    end
  end

  def minor_update
    document.draft? ? document.minor_update : false
  end

  def change_note
    document.draft? ? document.change_note : ""
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
