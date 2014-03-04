class PanopticonMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :document_id, type: String
  field :panopticon_id, type: String
  field :slug, type: String
end
