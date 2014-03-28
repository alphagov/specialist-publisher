class PanopticonMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :document_id, type: String
  field :panopticon_id, type: String
  field :slug, type: String

  def self.all_document_ids
    all.lazy.map(&:document_id)
  end
end
