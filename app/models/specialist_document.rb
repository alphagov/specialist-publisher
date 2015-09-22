require "forwardable"
require "active_model/conversion"
require "active_model/naming"

class SpecialistDocument
  extend Forwardable

  def self.edition_attributes
    [
      :title,
      :slug,
      :summary,
      :body,
      :document_type,
      :updated_at,
      :version_number,
      :extra_fields,
      # TODO: These fields expose the edition a little too directly, rethink?
      :change_note,
      :change_history,
      :minor_update,
      :public_updated_at
    ]
  end

  def_delegators :latest_edition, *edition_attributes

  attr_reader :id, :editions, :latest_edition

  def initialize(slug_generator, id, editions, edition_factory = SpecialistDocumentEdition.method(:new))
    @slug_generator = slug_generator
    @id = id
    @editions = editions
    @edition_factory = edition_factory
    @editions.push(create_first_edition) if @editions.empty?
    @latest_edition = @editions.last
  end

  def minor_update?
    !!minor_update
  end

  def to_param
    id
  end

  def extra_fields
    latest_edition.extra_fields.symbolize_keys
  end

  def attributes
    latest_edition
      .attributes
      .symbolize_keys
      .merge(extra_fields: extra_fields)
      .select { |k, _|
        self.class.edition_attributes.include?(k)
      }
      .merge(
        id: id,
      )
  end

  def update(params)
    # TODO: this is very defensive, we need enforce consistency of params at the boudary
    params = params
      .select { |k, _| allowed_update_params.include?(k.to_s) }
      .symbolize_keys

    if never_published? && params.fetch(:title, false)
      params = params.merge(
        slug: slug_generator.call(params.fetch(:title))
      )
    end

    if draft?
      latest_edition.assign_attributes(params)
    else
      @latest_edition = new_draft(params)
      editions.push(@latest_edition)
    end

    nil
  end

  def published?
    editions.any?(&:published?)
  end

  def draft?
    latest_edition.draft?
  end

  def add_attachment(attributes)
    latest_edition.build_attachment(attributes)
  end

  def attachments
    latest_edition.attachments.to_a
  end

  def publish!
    unless latest_edition.published?
      published_edition.archive if published_edition

      latest_edition.publish
    end
  end

  def withdraw!
    published_edition.archive if published_edition
  end

  def withdrawn?
    most_recent_non_draft && most_recent_non_draft.archived?
  end

  def find_attachment_by_id(attachment_id)
    attachments.find { |a| a.id.to_s == attachment_id }
  end

  def publication_state
    if withdrawn?
      "withdrawn"
    elsif published?
      "published"
    elsif draft?
      "draft"
    end
  end

  def published_edition
    if most_recent_non_draft && most_recent_non_draft.published?
      most_recent_non_draft
    end
  end

  def needs_exporting?
    latest_edition.exported_at.nil?
  end

  def mark_as_exported_to_live_publishing_api!
    edition = latest_edition
    edition.exported_at = Time.zone.now
    edition.save
  end

  def persisted?
    editions.any?(&:persisted?)
  end

protected

  attr_reader :slug_generator, :edition_factory

  def never_published?
    !published?
  end

  def new_edition_defaults
    {
      state: "draft",
      version_number: 1,
      # TODO: Remove persistence conern
      document_id: id,
    }
  end

  def create_first_edition
    edition_factory.call(new_edition_defaults)
  end

  def new_draft(params = {})
    new_edition_attributes = previous_edition_attributes
      .merge(new_edition_defaults)
      .merge(params)
      .merge(
        version_number: current_version_number + 1,
        slug: slug,
        document_type: document_type,
        attachments: attachments,
      )

    edition_factory.call(new_edition_attributes)
  end

  def current_version_number
    latest_edition.version_number
  end

  def most_recent_non_draft
    editions.reject { |e| e.draft? }.last
  end

  def previous_edition_attributes
    latest_edition.attributes
      .except(*no_copy_attributes)
      .symbolize_keys
  end

  def allowed_update_params
    self.class.edition_attributes
      .-(unupdatable_attributes)
      .map(&:to_s)
  end

  def unupdatable_attributes
    [
      :updated_at,
      :slug,
      :version_number,
    ]
  end

  def no_copy_attributes
    %w[
      _id
      created_at
      updated_at
      exported_at
    ]
  end
end
