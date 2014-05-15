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
    :opened_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type,
    :closed_date,
  ]

  document_methods = [
    :exposed_edition,
    :add_attachment,
    :attachments,
    :find_attachment_by_id,
    :errors,
    :valid?,
    :persisted?,
    :to_param,
  ]

  def_delegators(:document, *(document_methods + document_attributes))

  def initialize(manual, document)
    @manual = manual
    @document = document
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Document")
  end

private
  attr_reader :manual, :document
end
