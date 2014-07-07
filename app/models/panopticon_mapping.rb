class PanopticonMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :resource_id, type: String
  field :resource_type, type: String
  field :panopticon_id, type: String
  field :slug, type: String
end
