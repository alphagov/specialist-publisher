require "gds_api/panopticon"

class SpecialistDocumentRepository

  def initialize(panopticon_mappings,
    specialist_document_editions,
    panopticon_api,
    specialist_document_factory,
    specialist_document_publication_observers)
    @panopticon_mappings = panopticon_mappings
    @specialist_document_editions = specialist_document_editions
    @panopticon_api = panopticon_api
    @document_factory = specialist_document_factory
    @publication_observers = specialist_document_publication_observers
  end

  def all
    editions = specialist_document_editions.all
    document_ids = editions.map(&:document_id).uniq
    documents = document_ids.map { |id| fetch(id) }

    documents.sort_by(&:updated_at).reverse
  end

  def fetch(id)
    editions = specialist_document_editions.where(document_id: id).to_a

    if editions.empty?
       nil
    else
      document_factory.call(id, editions)
    end
  end

  def store!(document)
    artefact_attributes = artefact_attributes_for(document)
    edition = document.exposed_edition

    edition.document_id = document.id
    edition.slug = artefact_attributes[:slug]

    if edition.save
      unless panopticon_mappings.exists?(conditions: {document_id: document.id})
        response = create_artefact(artefact_attributes)
        panopticon_mappings.create!(
          document_id: document.id,
          panopticon_id: response['id'],
          slug: edition.slug,
        )
      end

      true
    else
      false
    end
  rescue GdsApi::HTTPErrorResponse => e
    if e.code == 422
      errors = e.error_details['errors'].symbolize_keys
      Rails.logger.info(errors)
      document.add_error(:title, errors.delete(:name)) if errors.has_key?(:name)
      errors.each do |field, message|
        document.add_error(field, message)
      end

      false
    else
      raise e
    end
  end

  def publish!(document)
    mapping = panopticon_mappings.where(document_id: document.id).last

    missing_registration_message = "Can't publish a document which is not registered with Panopticon"
    raise InvalidDocumentError.new(missing_registration_message, document) if mapping.nil?

    document_previously_published = document.published?

    document.publish!

    publication_observers.each { |o| o.call(document) }

    notify_panopticon_of_publish(mapping.panopticon_id, document) unless document_previously_published

    document.previous_editions.each(&:archive)
  end

  class InvalidDocumentError < Exception
    def initialize(message, document)
      super(message)
      @document = document
    end

    attr_reader :document
  end

private

  attr_reader(
    :panopticon_mappings,
    :specialist_document_editions,
    :panopticon_api,
    :document_factory,
    :publication_observers,
  )
  def create_artefact(artefact_attributes)
    panopticon_api.create_artefact!(artefact_attributes)
  end

  def notify_panopticon_of_publish(panopticon_id, document)
    panopticon_api.put_artefact!(panopticon_id, artefact_attributes_for(document, 'live'))
  end

  def artefact_attributes_for(document, state = 'draft')
    {
      name: document.title,
      slug: document.slug,
      kind: 'specialist-document',
      owning_app: 'specialist-publisher',
      rendering_app: 'specialist-frontend',
      paths: ["/#{document.slug}"],
      state: state
    }
  end

end
