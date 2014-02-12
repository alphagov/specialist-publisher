require "gds_api/panopticon"

class SpecialistDocumentRegistry

  def self.fetch(id, version: nil)
    return nil unless Artefact.find(id)

    editions = SpecialistDocumentEdition.where(panopticon_id: panopticon_id).order(:created_at)

    edition = if version
      editions.where(version_number: version).last
    else
      editions.last
    end

    SpecialistDocument.new(id: id, title: edition.title, summary: edition.summary, state: edition.state)
  end

  def self.store(document)
    new(document).store!
  end

  def initialize(document)
    @document = document
  end

  def store!
    unless document.id
      response = create_artefact
      document.id = response['id']
    end

    update_edition
  end

protected

  attr_reader :document

  def update_edition
    draft = find_or_create_draft
    draft.title = document.title
    draft.summary = document.summary
    draft.body = document.body

    draft.save!
  end

  def create_artefact
    panopticon_api.create_artefact!(name: document.title, slug: document.slug, kind: 'specialist-document', owning_app: 'specialist-publisher')
  end

  def panopticon_api
    @panopticon_api ||= GdsApi::Panopticon.new(Plek.current.find("panopticon"), CONTENT_API_CREDENTIALS)
  end

  def find_or_create_draft
    latest_edition = SpecialistDocumentEdition.where(panopticon_id: document.id).order(:created_at).last

    if latest_edition.nil?
      SpecialistDocumentEdition.new(panopticon_id: document.id, state: 'draft')
    elsif document.published?
      SpecialistDocumentEdition.new(panopticon_id: document.id, state: 'draft', version_number: (latest_edition.version_number + 1))
    end
  end

end
