class ManualRecord
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :manual_id, type: String
  field :organisation_slug, type: String
  field :slug, type: String

  embeds_many :editions,
    class_name: "ManualRecord::Edition",
    cascade_callbacks: true

  def self.find_by(attributes)
    first(conditions: attributes)
  end

  def self.find_by_organisation(organisation_slug)
    where(organisation_slug: organisation_slug)
  end

  def self.all_by_updated_at
    order_by([:updated_at, :desc])
  end

  def new_or_existing_draft_edition
    if latest_edition && latest_edition.state == "draft"
      latest_edition
    else
      build_draft_edition
    end
  end

  def latest_edition
    editions.order_by([:version_number, :desc]).first
  end

private
  def build_draft_edition
    editions.build(state: "draft", version_number: next_version_number)
  end

  def next_version_number
    current_version_number + 1
  end

  def current_version_number
    latest_edition && latest_edition.version_number || 0
  end

  class Edition
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    field :title, type: String
    field :summary, type: String
    field :body, type: String
    field :state, type: String
    field :version_number, type: Integer
    field :document_ids, type: Array
    field :removed_document_ids, type: Array
    field :tags, type: Array

    # We don't make use of the relationship but Mongiod can't save the
    # timestamps properly without it.
    embedded_in "ManualRecord"
  end
end
