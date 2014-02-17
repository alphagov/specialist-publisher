require "gds_api/panopticon"

class SpecialistDocumentRegistry < Struct.new(:artefacts, :specialist_document_editions, :panopticon_api)

  def all
    artefacts.where(kind: 'specialist-document').desc(:updated_at).map do |artefact|
      fetch(artefact.id)
    end.compact
  end

  def fetch(id, version_number: nil)
    return nil unless artefacts.find(id)

    editions = specialist_document_editions.where(panopticon_id: id).order(:created_at)

    edition = if version_number
      editions.where(version_number: version_number).last
    else
      editions.last
    end

    return nil if edition.nil?

    SpecialistDocument.new(
      id: id,
      title: edition.title,
      summary: edition.summary,
      body: edition.body,
      opened_date: edition.opened_date,
      closed_date: edition.closed_date,
      case_type: edition.case_type,
      case_state: edition.case_state,
      market_sector: edition.market_sector,
      outcome_type: edition.outcome_type,
      updated_at: edition.updated_at
    )
  end

  def store!(document)
    unless document.id
      response = create_artefact(document)
      document.id = response['id']
    end

    update_edition(document)
  rescue GdsApi::HTTPErrorResponse => e
    if e.code == 422
      errors = e.error_details['errors'].with_indifferent_access
      Rails.logger.info(errors)
      errors[:title] = errors.delete(:name)
      document.errors = errors
      raise InvalidDocumentError.new("Can't store an invalid document #{errors}", document)
    else
      raise e
    end
  end

  def publish!(document)
    raise InvalidDocumentError.new("Can't publish a non-existant document", document) if document.id.nil?

    artefact = artefacts.find(document.id)
    latest_edition = specialist_document_editions.where(panopticon_id: document.id).last

    latest_edition.emergency_publish unless latest_edition.published?

    update_artefact(document, 'live') unless artefact.live?
  end

  class InvalidDocumentError < Exception
    def initialize(message, document)
      super(message)
      @document = document
    end

    attr_reader :document
  end

protected

  def update_edition(document)
    draft = find_or_create_draft(document)
    draft.title = document.title
    draft.summary = document.summary
    draft.body = document.body
    draft.opened_date = document.opened_date
    draft.closed_date = document.closed_date
    draft.case_type = document.case_type
    draft.case_state = document.case_state
    draft.market_sector = document.market_sector
    draft.outcome_type = document.outcome_type

    draft.save!
  end

  def create_artefact(document)
    panopticon_api.create_artefact!(name: document.title, slug: document.slug, kind: 'specialist-document', owning_app: 'specialist-publisher')
  end

  def update_artefact(document, artefact_state)
    panopticon_api.put_artefact!(document.id, name: document.title, slug: document.slug, kind: 'specialist-document', owning_app: 'specialist-publisher', state: artefact_state)
  end

  def find_or_create_draft(document)
    latest_edition = specialist_document_editions.where(panopticon_id: document.id).order(:created_at).last

    if latest_edition.nil?
      specialist_document_editions.new(panopticon_id: document.id, state: 'draft')
    else
      if latest_edition.published?
        specialist_document_editions.new(panopticon_id: document.id, state: 'draft', version_number: (latest_edition.version_number + 1))
      else
        latest_edition
      end
    end
  end

end
