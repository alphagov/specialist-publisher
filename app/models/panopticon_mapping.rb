class PanopticonMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :resource_id, type: String
  field :resource_type, type: String
  field :panopticon_id, type: String
  field :slug, type: String

  scope :documents, where(resource_type: "specialist-document")
  scope :manuals, where(resource_type: "manuals")

  def self.all_document_ids
    documents.lazy.map(&:resource_id)
  end
end
