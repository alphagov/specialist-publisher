require "gds_api/panopticon"

class SpecialistDocumentRepository

  def initialize(panopticon_mappings,
    specialist_document_editions,
    panopticon_api,
    specialist_document_factory,
    slug_generator)
    @panopticon_mappings = panopticon_mappings
    @specialist_document_editions = specialist_document_editions
    @panopticon_api = panopticon_api
    @document_factory = specialist_document_factory
    @slug_generator = slug_generator
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
    edition = document.latest_edition

    edition.document_id = document.id

    if edition.save
      unless panopticon_mappings.exists?(conditions: {document_id: document.id})
        response = create_artefact(document)
        panopticon_mappings.create!(
          document_id: document.id,
          panopticon_id: response['id'],
          slug: response['slug']
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

    latest_edition = document.latest_edition
    latest_edition.emergency_publish unless latest_edition.published?

    notify_panopticon_of_publish(mapping.panopticon_id, document) unless document_previously_published
  end

  class InvalidDocumentError < Exception
    def initialize(message, document)
      super(message)
      @document = document
    end

    attr_reader :document
  end

private

  attr_reader :panopticon_mappings, :specialist_document_editions, :panopticon_api, :document_factory

  def create_artefact(document)
    panopticon_api.create_artefact!(artefact_attributes_for(document))
  end

  def notify_panopticon_of_publish(panopticon_id, document)
    panopticon_api.put_artefact!(panopticon_id, artefact_attributes_for(document, 'live'))
  end

  def artefact_attributes_for(document, state = 'draft')
    slug = @slug_generator.generate_slug(document)

    {
      name: document.title,
      slug: slug,
      kind: 'specialist-document',
      owning_app: 'specialist-publisher',
      rendering_app: 'specialist-frontend',
      paths: ["/#{slug}"],
      state: state
    }
  end

end
