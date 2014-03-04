require "forwardable"

class SpecialistDocument
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend Forwardable

  def self.edition_attributes
    [
      :title,
      :summary,
      :body,
      :opened_date,
      :closed_date,
      :case_type,
      :case_state,
      :market_sector,
      :outcome_type,
      :updated_at,
    ]
  end

  def_delegators :latest_edition, *edition_attributes

  attr_reader :id, :editions

  def initialize(edition_factory, id, editions)
    @edition_factory = edition_factory
    @id = id
    @editions = editions.sort_by(&:version_number)
  end

  def update(params)
    if latest_edition.published?
      editions.push(new_draft(params))
    else
      latest_edition.assign_attributes(params)
    end

    self
  end

  def valid?
    latest_edition.valid?
  end

  def published?
    editions.any?(&:published?)
  end

  def draft?
    latest_edition.draft?
  end

  def errors
    latest_edition.errors.messages
  end

  def add_error(field, message)
    latest_edition.errors[field] ||= []
    latest_edition.errors[field] += message
  end

  def latest_edition
    @editions.last || create_first_edition
  end

  def previous_editions
    @editions[0...-1]
  end

  # TODO: remove this persistence concern
  def persisted?
    updated_at.present?
  end

protected

  attr_reader :edition_factory

  def new_edition_defaults
    {
      state: "draft",
      version_number: 1
    }
  end

  def create_first_edition
    edition_factory.call(new_edition_defaults).tap { |e|
      editions.push(e)
    }
  end

  def new_draft(params = {})
    edition_params = params
      .merge(new_edition_defaults)
      .merge(version_number: current_version_number + 1)

    edition_factory.call(edition_params)
  end

  def current_version_number
    latest_edition.version_number
  end
end
