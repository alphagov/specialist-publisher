require "dependency_container"
require "id_generator"
require "specialist_document_repository"
require "builders/cma_case_builder"
require "builders/aaib_report_builder"
require "gds_api/rummager"
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
require "rummager_indexer"
require "cma_case_indexable_formatter"
require "null_finder_schema"
require "aaib_report_indexable_formatter"

$LOAD_PATH.unshift(File.expand_path("../..", "app/services"))

SpecialistPublisherWiring = DependencyContainer.new do

  define_factory(:observers) {
    ObserversRegistry.new(
      aaib_report_content_api_exporter: get(:aaib_report_content_api_exporter),
      finder_api_notifier: get(:finder_api_notifier),
      aaib_report_panopticon_registerer: get(:aaib_report_panopticon_registerer),
      manual_panopticon_registerer: get(:manual_panopticon_registerer),
      manual_document_panopticon_registerer: get(:manual_document_panopticon_registerer),
      manual_content_api_exporter: get(:manual_and_documents_content_api_exporter),
      aaib_report_rummager_indexer: get(:aaib_report_rummager_indexer),
      specialist_document_content_api_withdrawer: get(:specialist_document_content_api_withdrawer),
      finder_api_withdrawer: get(:finder_api_withdrawer),
      aaib_report_rummager_deleter: get(:aaib_report_rummager_deleter),
    )
  }

  define_factory(:services) {
    ServiceRegistry.new(
      cma_case_repository: get(:cma_case_repository),
      document_renderer: get(:specialist_document_renderer),
      manual_repository_factory: get(:manual_repository_factory),
      manual_document_builder: get(:manual_document_builder),
      observers: get(:observers),
    )
  }

  define_factory(:aaib_report_attachment_services) {
    AaibReportAttachmentServiceRegistery.new(
      aaib_report_repository: get(:aaib_report_repository),
    )
  }

  define_factory(:manual_builder) {
    ->(attrs) {
      slug_generator = SlugGenerator.new(prefix: "guidance")

      default = {
        id: IdGenerator.call,
        slug: slug_generator.call(attrs.fetch(:title)),
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

  define_singleton(:aaib_report_repository) do
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "aaib_report"),
      document_factory: get(:validatable_aaib_report_factory),
    )
  end

  define_singleton(:cma_case_repository) do
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "cma_case"),
      document_factory: get(:validatable_cma_case_factory),
    )
  end

  define_singleton(:manual_specific_document_repository_factory) do
    ->(manual) {
      document_factory = get(:validated_manual_document_factory_factory).call(manual)

      SpecialistDocumentRepository.new(
        specialist_document_editions: SpecialistDocumentEdition.where(document_type: "manual"),
        document_factory: document_factory,
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

  define_singleton(:edition_factory) { SpecialistDocumentEdition.method(:new) }

  define_factory(:cma_case_builder) {
    CmaCaseBuilder.new(
      get(:validatable_cma_case_factory),
      IdGenerator,
    )
  }

  define_factory(:validatable_cma_case_factory) {
    ->(*args) {
      SlugUniquenessValidator.new(
        get(:cma_case_repository),
        CmaCaseForm.new(
          CmaCase.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "cma-cases"),
              get(:edition_factory),
              *args,
            ),
          ),
        ),
      )
    }
  }

  define_factory(:aaib_report_builder) {
    AaibReportBuilder.new(
      get(:validatable_aaib_report_factory),
      IdGenerator,
    )
  }

  define_factory(:validatable_aaib_report_factory) {
    ->(*args) {
      SlugUniquenessValidator.new(
        get(:aaib_report_repository),
        AaibReportForm.new(
          AaibReport.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "aaib-reports"),
              get(:edition_factory),
              *args,
            )
          )
        ),
      )
    }
  }

  define_factory(:manual_document_builder) {
    ManualDocumentBuilder.new(
      factory_factory: get(:validated_manual_document_factory_factory),
      id_generator: IdGenerator,
    )
  }

  define_factory(:validated_manual_document_factory_factory) {
    ->(manual) {
      ->(id, editions) {
        slug_generator = SlugGenerator.new(prefix: manual.slug)

        ChangeNoteValidator.new(
          SlugUniquenessValidator.new(
            # TODO This doesn't look right!
            get(:cma_case_repository),
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

  define_instance(:markdown_renderer) {
    SpecialistDocumentAttachmentProcessor.method(:new)
  }

  define_instance(:govspeak_html_converter) {
    ->(string) {
      Govspeak::Document.new(string).to_html
    }
  }

  define_instance(:govspeak_header_extractor) {
    ->(string) {
      Govspeak::Document.new(string).structured_headers
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

  define_instance(:specialist_document_renderer) {
    ->(doc) {
      pipeline = [
        get(:markdown_renderer),
        get(:specialist_document_govspeak_header_extractor),
        get(:specialist_document_govspeak_to_html_renderer),
      ]

      pipeline.reduce(doc) { |doc, next_renderer|
        next_renderer.call(doc)
      }
    }
  }

  define_factory(:panopticon_registerer) {
    ->(artefact) {
      PanopticonRegisterer.new(
        mappings: PanopticonMapping,
        artefact: artefact,
      ).call
    }
  }

  define_factory(:cma_case_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        CmaCaseArtefactFormatter.new(document)
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

  define_factory(:cma_case_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        CmaCaseIndexableFormatter.new(
          SpecialistDocumentAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:cma_case_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        CmaCaseIndexableFormatter.new(
          SpecialistDocumentAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:aaib_report_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        AaibReportIndexableFormatter.new(
          SpecialistDocumentAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:aaib_report_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        AaibReportIndexableFormatter.new(
          SpecialistDocumentAttachmentProcessor.new(document)
        )
      )
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

  define_instance(:aaib_report_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:aaib_report_finder_schema),
        doc,
      ).call
    }
  }

  define_instance(:cma_case_content_api_exporter) {
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
        NullFinderSchema.new,
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

  define_singleton(:finder_api) {
    FinderAPI.new(Faraday, Plek.current)
  }

  define_singleton(:finder_api_notifier) {
    FinderAPINotifier.new(get(:finder_api), get(:markdown_renderer))
  }

  define_singleton(:rummager_api) {
    GdsApi::Rummager.new(Plek.new.find("search"))
  }

  define_singleton(:aaib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/aaib-reports.json"))
  }

  define_singleton(:cma_case_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/cma-cases.json"))
  }

end
