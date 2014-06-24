require "dependency_container"
require "securerandom"
require "specialist_document_repository"
require "builders/specialist_document_builder"
require "gds_api/panopticon"
require "panopticon_registerer"
require "specialist_document_attachment_processor"
require "specialist_document_database_exporter"
require "manual_database_exporter"
require "rendered_specialist_document"
require "specialist_document_govspeak_to_html_renderer"
require "specialist_document_header_extractor"
require "finder_api_notifier"
require "finder_api"
require "validators/slug_uniqueness_validator"
require "validators/change_note_validator"
require "marshallers/document_association_marshaller"
require "builders/manual_document_builder"

$LOAD_PATH.unshift(File.expand_path("../..", "app/services"))

SpecialistPublisherWiring = DependencyContainer.new do

  define_factory(:observers) {
    ObserversRegistry.new(
      document_content_api_exporter: get(:specialist_document_content_api_exporter),
      finder_api_notifier: get(:finder_api_notifier),
      document_panopticon_registerer: get(:document_panopticon_registerer),
      aaib_report_panopticon_registerer: get(:aaib_report_panopticon_registerer),
      manual_panopticon_registerer: get(:manual_panopticon_registerer),
      manual_document_panopticon_registerer: get(:manual_document_panopticon_registerer),
      manual_content_api_exporter: get(:manual_and_documents_content_api_exporter),
    )
  }

  define_factory(:services) {
    ServiceRegistry.new(
      document_builder: get(:cma_case_builder),
      aaib_report_builder: get(:aaib_report_builder),
      document_repository: get(:specialist_document_repository),
      aaib_report_repository: get(:aaib_report_repository),
      creation_listeners: get(:specialist_document_creation_observers),
      aaib_report_creation_listeners: get(:aaib_report_creation_observers),
      withdrawal_listeners: get(:specialist_document_withdrawal_observers),
      document_renderer: get(:specialist_document_renderer),

      manual_repository_factory: get(:manual_repository_factory),
      manual_builder: get(:manual_builder),

      observers: get(:observers),
    )
  }

  define_factory(:manual_builder) {
    ->(attrs) {
      default = {
        id: SecureRandom.uuid,
        slug: get(:manual_slug_generator).call(attrs.fetch(:title)),
        summary: "",
        state: "draft",
        organisation_slug: "",
        updated_at: "",
      }

      ManualWithDocuments.new(
        get(:manual_document_builder),
        Manual.new(default.merge(attrs)),
        documents: [],
      )
    }
  }

  define_instance(:specialist_document_editions) { SpecialistDocumentEdition }
  define_instance(:artefacts) { Artefact }
  define_instance(:panopticon_mappings) { PanopticonMapping }
  define_singleton(:panopticon_api) do
    GdsApi::Panopticon.new(get(:plek).find("panopticon"), PANOPTICON_API_CREDENTIALS)
  end

  define_singleton(:cma_case_factory) {
    ->(*args) {
      CmaCase.new(
        SpecialistDocument.new(
          get(:cma_slug_generator),
          get(:edition_factory),
          *args,
        )
      )
    }
  }

  define_singleton(:aaib_report_factory) {
    ->(*args) {
      AaibReport.new(
        SpecialistDocument.new(
          get(:aaib_slug_generator),
          get(:edition_factory),
          *args,
        )
      )
    }
  }

  define_singleton(:aaib_report_repository) do
    SpecialistDocumentRepository.new(
      get(:panopticon_mappings),
      get(:specialist_document_editions).where(document_type: "aaib_report"),
      get(:validatable_aaib_report_factory),
    )
  end

  define_singleton(:specialist_document_repository) do
    SpecialistDocumentRepository.new(
      get(:panopticon_mappings),
      get(:specialist_document_editions).where(document_type: "cma_case"),
      get(:validatable_cma_case_factory),
    )
  end

  define_singleton(:manual_specific_document_repository_factory) do
    ->(manual) {
      document_factory = get(:validated_manual_document_factory_factory).call(manual)

      SpecialistDocumentRepository.new(
        get(:panopticon_mappings),
        get(:specialist_document_editions).where(document_type: "manual"),
        document_factory,
      )
    }
  end

  define_factory(:manual_repository_factory) {
    ->(organisation_slug) {
      get(:plain_manual_repository_factory).call(
        organisation_slug: organisation_slug,
        association_marshallers: [
          DocumentAssociationMarshaller.new(
            manual_specific_document_repository_factory: get(:manual_specific_document_repository_factory),
            decorator: ->(manual, attrs) {
              ManualWithDocuments.new(
                get(:manual_document_builder),
                manual,
                attrs,
              )
            }
          ),
        ],
      )
    }
  }

  define_factory(:plain_manual_repository_factory) {
    ->(dependencies) {
      ManualRepository.new(
        {
          association_marshallers: [],
          factory: Manual.method(:new),
          collection: ManualRecord.find_by_organisation(
            dependencies.fetch(:organisation_slug)
          ),
        }.merge(dependencies.except(:organisation_slug))
      )
    }
  }

  define_singleton(:id_generator) { SecureRandom.method(:uuid) }

  define_singleton(:edition_factory) { SpecialistDocumentEdition.method(:new) }
  define_singleton(:attachment_factory) { Attachment.method(:new) }

  define_factory(:cma_case_builder) {
    SpecialistDocumentBuilder.new(
      get(:validatable_cma_case_factory),
      get(:id_generator),
    )
  }

  define_factory(:validatable_cma_case_factory) {
    ->(*args) {
      SlugUniquenessValidator.new(
        get(:specialist_document_repository),
        CmaCaseForm.new(
          get(:cma_case_factory).call(*args),
        ),
      )
    }
  }

  define_factory(:aaib_report_builder) {
    SpecialistDocumentBuilder.new(
      get(:validatable_aaib_report_factory),
      get(:id_generator),
    )
  }

  define_factory(:validatable_aaib_report_factory) {
    ->(*args) {
      SlugUniquenessValidator.new(
        get(:aaib_report_repository),
        AaibReportForm.new(
          get(:aaib_report_factory).call(*args),
        ),
      )
    }
  }

  define_factory(:manual_document_builder) {
    ManualDocumentBuilder.new(
      factory_factory: get(:validated_manual_document_factory_factory),
      id_generator: get(:id_generator),
    )
  }

  define_factory(:validated_manual_document_factory_factory) {
    ->(manual) {
      ->(id, editions) {
        slug_generator = get(:manual_document_slug_generator).call(manual.slug)

        ChangeNoteValidator.new(
          SlugUniquenessValidator.new(
            get(:specialist_document_repository),
            SpecialistDocument.new(
              slug_generator,
              get(:edition_factory),
              id,
              editions,
            )
          )
        )
      }
    }
  }

  define_factory(:cma_slug_generator) { SlugGenerator.new(prefix: "cma-cases") }
  define_factory(:aaib_slug_generator) { SlugGenerator.new(prefix: "aaib-reports") }
  define_factory(:manual_slug_generator) { SlugGenerator.new(prefix: "guidance") }
  define_factory(:manual_document_slug_generator) {
    ->(manual_slug) {
      SlugGenerator.new(prefix: manual_slug)
    }
  }

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

  define_singleton(:specialist_document_creation_observers) {
    [
      get(:document_panopticon_registerer),
    ]
  }

  define_singleton(:aaib_report_creation_observers) {
    [
      get(:aaib_report_panopticon_registerer),
    ]
  }

  define_singleton(:specialist_document_withdrawal_observers) {
    [
      get(:specialist_document_content_api_withdrawer),
      get(:finder_api_withdrawer),
      get(:document_panopticon_registerer),
    ]
  }

  define_factory(:panopticon_registerer) {
    ->(artefact) {
      PanopticonRegisterer.new(
        api_client: get(:panopticon_api),
        mappings: get(:panopticon_mappings),
        artefact: artefact,
      ).call
    }
  }

  define_factory(:document_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        DocumentArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:aaib_report_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        AaibReportArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:manual_document_panopticon_registerer) {
    ->(document, manual) {
      get(:panopticon_registerer).call(
        ManualDocumentArtefactFormatter.new(document, manual)
      )
    }
  }

  define_factory(:manual_panopticon_registerer) {
    ->(manual) {
      get(:panopticon_registerer).call(
        ManualArtefactFormatter.new(manual)
      )

      get(:panopticon_registerer).call(
        ManualChangeNotesArtefactFormatter.new(manual)
      )

      manual.respond_to?(:documents) && manual.documents.each do |doc|
        get(:manual_document_panopticon_registerer).call(doc, manual)
      end
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
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:cma_case_finder_schema),
        doc,
      ).call
    }
  }

  define_factory(:manual_document_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:null_finder_schema),
        doc,
      ).call
    }
  }

  define_factory(:manual_content_api_exporter) {
    ->(manual) {
      ManualDatabaseExporter.new(
        RenderedManual,
        manual,
      ).call
    }
  }

  define_factory(:manual_and_documents_content_api_exporter) {
    ->(manual) {

      get(:manual_content_api_exporter).call(manual)

      manual.documents.each do |exportable|
        get(:manual_document_content_api_exporter).call(exportable)
      end
    }
  }

  define_factory(:null_finder_schema) {
    OpenStruct.new(facets: [])
  }

  define_singleton(:http_client) { Faraday }

  define_singleton(:finder_api) {
    FinderAPI.new(get(:http_client), get(:plek))
  }

  define_singleton(:finder_api_notifier) {
    FinderAPINotifier.new(get(:finder_api), get(:markdown_renderer))
  }

  define_singleton(:aaib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/aaib-reports.json"))
  }

  define_singleton(:cma_case_finder_schema) {
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

end
