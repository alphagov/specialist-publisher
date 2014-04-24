require "forwardable"
require "active_model/conversion"
require "active_model/naming"

class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend Forwardable

  def self.edition_attributes
    [
      :title,
      :slug,
      :summary,
      :body,
      :opened_date,
      :closed_date,
      :case_type,
      :case_state,
      :market_sector,
      :outcome_type,
      :updated_at,
      :version_number
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
    self.id
  end

  def attributes
    exposed_edition.attributes
      .symbolize_keys
      .select { |k, v|
        self.class.edition_attributes.include?(k)
      }
      .merge(
        id: id,
      )
  end

  def published_version
    published_edition = editions.select(&:published?).last
    if published_edition
      self.class.new(@slug_generator, @edition_factory, @id, @editions, version_number: published_edition.version_number)
    end
  end

  def finder_slug
    slug.split('/').first
  end

  def update(params)
    raise "Can only update the latest version" unless latest_edition_exposed?

    if never_published? && params.fetch(:title, false)
      params = params.merge(
        slug: slug_generator.call(params.fetch(:title))
      )
    end

    if exposed_edition.published?
      @exposed_edition = new_draft(params)
      editions.push(@exposed_edition)
    else
      exposed_edition.assign_attributes(params)
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


  def previous_editions
    @editions[0...-1]
  end

  # TODO: remove this persistence concern
  def persisted?
    updated_at.present?
  end

  def add_attachment(attributes)
    exposed_edition.build_attachment(attributes)
  end

  def attachments
    exposed_edition.attachments.to_a
  end

  def publish!
    raise "Can only publish the latest edition" unless latest_edition_exposed?
    latest_edition.publish unless latest_edition.published?
  end

  def latest_edition_exposed?
    latest_edition == exposed_edition
  end

  def find_attachment_by_id(attachment_id)
    attachments.find { |a| a.id.to_s == attachment_id }
  end

protected

  attr_reader :slug_generator, :edition_factory

  def never_published?
    !published?
  end

  def new_edition_defaults
    {
      state: "draft",
      version_number: 1
    }
  end

  def create_first_edition
    edition_factory.call(new_edition_defaults)
  end

  def latest_edition
    @editions.last
  end

  def new_draft(params = {})
    edition_params = params
      .merge(new_edition_defaults)
      .merge(
        version_number: current_version_number + 1,
        slug: slug,
        attachments: attachments,
        # TODO: Remove persistence conern
        document_id: id,
      )

    edition_factory.call(edition_params)
  end

  def current_version_number
    exposed_edition.version_number
  end
end
