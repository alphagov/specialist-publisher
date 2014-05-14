require 'dependency_container'
require 'securerandom'
require "specialist_document_repository"
require 'builders/specialist_document_builder'
require 'gds_api/panopticon'
require 'panopticon_registerer'
require "specialist_document_attachment_processor"
require "specialist_document_exporter"
require "rendered_specialist_document"
require "specialist_document_govspeak_to_html_renderer"
require "specialist_document_header_extractor"
require "finder_api_notifier"
require "finder_api"
require "validators/slug_uniqueness_validator"
require "marshallers/document_association_marshaller"

$LOAD_PATH.unshift(File.expand_path("../..", "app/services"))

SpecialistPublisherWiring = DependencyContainer.new do
  define_instance(:specialist_document_editions) { SpecialistDocumentEdition }
  define_instance(:artefacts) { Artefact }
  define_instance(:panopticon_mappings) { PanopticonMapping }
  define_singleton(:panopticon_api) do
    GdsApi::Panopticon.new(get(:plek).find("panopticon"), PANOPTICON_API_CREDENTIALS)
  end

  define_singleton(:specialist_document_factory) {
    ->(*args) {
      SpecialistDocument.new(
        get(:slug_generator),
        get(:edition_factory),
        *args,
      )
    }
  }

  define_singleton(:specialist_document_repository) do
    build_with_dependencies(SpecialistDocumentRepository)
  end

  define_factory(:manual_repository_factory) {
    ->(organisation_slug) {
      ManualRepository.new(
        association_marshallers: [
          DocumentAssociationMarshaller.new(
            document_repository: get(:specialist_document_repository),
            decorator: ManualWithDocuments.method(:new),
          ),
        ],
        factory: Manual.method(:new),
        collection: ManualRecord.find_by_organisation(organisation_slug),
      )
    }
  }

  define_singleton(:id_generator) { SecureRandom.method(:uuid) }

  define_singleton(:edition_factory) { SpecialistDocumentEdition.method(:new) }
  define_singleton(:attachment_factory) { Attachment.method(:new) }

  define_factory(:specialist_document_builder) {
    SpecialistDocumentBuilder.new(
      ->(*args) {
        SlugUniquenessValidator.new(
          get(:specialist_document_repository),
          get(:specialist_document_factory).call(*args),
        )
      },
      get(:id_generator),
    )
  }

  define_instance(:slug_generator) { SlugGenerator }

  define_instance(:markdown_renderer) {
    SpecialistDocumentAttachmentProcessor.method(:new)
  }

  define_instance(:govspeak_document_factory) {
    Govspeak::Document.method(:new)
  }

  define_instance(:govspeak_html_converter) {
    ->(string) {
      get(:govspeak_document_factory).call(string).to_html
    }
  }

  define_instance(:govspeak_header_extractor) {
    ->(string) {
      get(:govspeak_document_factory).call(string).structured_headers
    }
  }

  define_instance(:specialist_document_govspeak_to_html_renderer) {
    ->(doc) {
      SpecialistDocumentGovspeakToHTMLRenderer.new(
        get(:govspeak_html_converter),
        doc,
      )
    }
  }

  define_instance(:specialist_document_govspeak_header_extractor) {
    ->(doc) {
      SpecialistDocumentHeaderExtractor.new(
        get(:govspeak_header_extractor),
        doc,
      )
    }
  }

  define_instance(:specialist_document_render_pipeline) {
    [
      get(:markdown_renderer),
      get(:specialist_document_govspeak_header_extractor),
      get(:specialist_document_govspeak_to_html_renderer),
    ]
  }

  define_instance(:specialist_document_renderer) {
    ->(doc) {
      get(:specialist_document_render_pipeline).reduce(doc) { |doc, next_renderer|
        next_renderer.call(doc)
      }
    }
  }

  define_singleton(:specialist_document_publication_observers) {
    [
      get(:specialist_document_content_api_exporter),
      get(:finder_api_notifier),
      get(:panopticon_registerer),
    ]
  }

  define_singleton(:specialist_document_creation_observers) {
    [
      get(:panopticon_registerer),
    ]
  }

  define_singleton(:specialist_document_withdrawal_observers) {
    [
      get(:specialist_document_content_api_withdrawer),
      get(:finder_api_withdrawer),
      get(:panopticon_registerer),
    ]
  }

  define_factory(:panopticon_registerer) {
    ->(document) {
      PanopticonRegisterer.new(
        get(:panopticon_api),
        get(:panopticon_mappings),
        document,
      ).call
    }
  }

  define_factory(:specialist_document_content_api_withdrawer) {
    ->(document) {
      RenderedSpecialistDocument.where(slug: document.slug).map(&:destroy)
    }
  }

  define_factory(:finder_api_withdrawer) {
    ->(doc) {
      get(:finder_api).notify_of_withdrawal(doc.slug)
    }
  }

  define_instance(:specialist_document_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:finder_schema),
        doc,
      ).call
    }
  }

  define_singleton(:http_client) { Faraday }

  define_singleton(:finder_api) {
    FinderAPI.new(get(:http_client), get(:plek))
  }

  define_singleton(:finder_api_notifier) {
    FinderAPINotifier.new(get(:finder_api), get(:markdown_renderer))
  }

  define_singleton(:finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/cma-cases.json"))
  }

  define_singleton(:plek) {
    Plek.current
  }

  define_singleton(:url_maker) {
    require "url_maker"
    UrlMaker.new(plek: get(:plek))
  }

  define_factory(:services) {
    ServiceRegistry.new(
      get(:specialist_document_builder),
      get(:specialist_document_repository),
      get(:specialist_document_publication_observers),
      get(:specialist_document_creation_observers),
      get(:specialist_document_withdrawal_observers),
    )
  }
end
