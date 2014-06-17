require "forwardable"

class ManualDocumentForm
  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  document_attributes = [
    :id,
    :title,
    :summary,
    :body,
    :minor_update,
  ]

  document_methods = [
    :exposed_edition,
    :add_attachment,
    :attachments,
    :find_attachment_by_id,
    :errors,
    :valid?,
  ]

  def_delegators(:document, *(document_methods + document_attributes))

  def initialize(manual, document)
    @manual = manual
    @document = document
    @errors = {}
  end

  def persisted?
    document.updated_at || document.published?
  end

  def minor_update
    document.draft? ? document.minor_update : false
  end

  def change_note
    document.draft? ?  document.change_note : ""
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
