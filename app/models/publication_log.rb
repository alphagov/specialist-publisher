class PublicationLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug, type: String
  field :title, typ: String
  field :change_note, type: String

  alias_attribute :published_at, :created_at

  def self.with_slug_prefix(slug)
    where(slug: /^#{slug}.*/)
      .order(:created_at)
  end
end
