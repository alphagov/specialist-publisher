require "state_machine"

class SpecialistDocumentEdition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :document_id,          type: String
  field :document_type,        type: String
  field :version_number,       type: Integer,  default: 1
  field :title,                type: String
  field :slug,                 type: String
  field :summary, type: String
  field :body, type: String
  field :state, type: String
  field :extra_fields, type: Hash, default: {}
  field :change_note, type: String
  field :minor_update, type: Boolean

  validates :document_id, presence: true
  validates :document_type, presence: true
  validates :slug, presence: true

  embeds_many :attachments, cascade_callbacks: true

  state_machine initial: :draft do
    event :publish do
      transition draft: :published
    end

    event :archive do
      transition all => :archived, :unless => :archived?
    end
  end

  scope :draft,               where(state: "draft")
  scope :published,           where(state: "published")
  scope :archived,            where(state: "archived")

  index "document_id"
  index "state"

  def build_attachment(attributes)
    attachments.build(attributes.merge(
      filename: attributes.fetch(:file).original_filename
    ))
  end

  def build_basic_attachment(attributes)
    attachments.build(attributes)
  end
end
