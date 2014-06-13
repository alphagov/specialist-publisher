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
    ]
  end

  def_delegators :exposed_edition, *edition_attributes

  attr_reader :id, :editions, :exposed_edition

  def initialize(slug_generator, edition_factory, id, editions, version_number: nil)
    @slug_generator = slug_generator
    @edition_factory = edition_factory
    @id = id
    @editions = editions
    @editions.push(create_first_edition) if @editions.empty?
    @exposed_edition = if version_number
      @editions.find { |e| e.version_number == version_number }
    else
      @editions.last
    end
  end

  def to_param
    id
  end

  def extra_fields
    exposed_edition.extra_fields.symbolize_keys
  end

  def attributes
    exposed_edition
      .attributes
      .symbolize_keys
      .merge(extra_fields: extra_fields)
      .select { |k, v|
        self.class.edition_attributes.include?(k)
      }
      .merge(
        id: id,
      )
  end

  def published_version
    if published_edition
      self.class.new(@slug_generator, @edition_factory, @id, @editions, version_number: published_edition.version_number)
    end
  end

  def update(params)
    raise "Can only update the latest version" unless latest_edition_exposed?

    # TODO: this is very defensive, we need enforce consistency of params at the boudary
    params = params
      .select { |k, v| allowed_update_params.include?(k.to_s) }
      .symbolize_keys

    if never_published? && params.fetch(:title, false)
      params = params.merge(
        slug: slug_generator.call(params.fetch(:title))
      )
    end

    if draft?
      exposed_edition.assign_attributes(params)
    else
      @exposed_edition = new_draft(params)
      editions.push(@exposed_edition)
    end

    self
  end

  def valid?
    exposed_edition.valid?
  end

  def published?
    editions.any?(&:published?)
  end

  def draft?
    exposed_edition.draft?
  end

  def errors
    exposed_edition.errors.messages
  end

  def add_error(field, message)
    exposed_edition.errors[field] ||= []
    exposed_edition.errors[field] += message
  end

  def add_attachment(attributes)
    exposed_edition.build_attachment(attributes)
  end

  def attachments
    exposed_edition.attachments.to_a
  end

  def publish!
    raise "Can only publish the latest edition" unless latest_edition_exposed?
    unless latest_edition.published?
      if published_edition
        published_edition.archive
      end

      latest_edition.publish
    end
  end

  def withdraw!
    if published_edition
      published_edition.archive
    end
  end

  def withdrawn?
    most_recent_non_draft && most_recent_non_draft.archived?
  end

  def latest_edition_exposed?
    latest_edition == exposed_edition
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

  def latest_edition
    @editions.last
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
    exposed_edition.version_number
  end

  def published_edition
    if most_recent_non_draft && most_recent_non_draft.published?
      most_recent_non_draft
    end
  end

  def most_recent_non_draft
    editions.reject { |e| e.draft? }.last
  end

  def previous_edition_attributes
    exposed_edition.attributes
      .except("_id", "updated_at")
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
end
