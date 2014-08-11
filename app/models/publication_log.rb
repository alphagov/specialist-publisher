class PublicationLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug, type: String
  field :title, typ: String
  field :change_note, type: String
  field :version_number, type: Integer

  validates :slug, presence: true
  validates :version_number, presence: true

  alias_attribute :published_at, :created_at

  def self.with_slug_prefix(slug)
    where(slug: /^#{slug}.*/)
      .order(:created_at)
  end
end
