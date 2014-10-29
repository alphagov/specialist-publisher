require "aaib_report_indexable_formatter"
require "builders/manual_builder"
require "builders/manual_document_builder"
require "builders/specialist_document_builder"
require "cma_case_indexable_formatter"
require "dependency_container"
require "document_headers_depth_limiter"
require "drug_safety_update_indexable_formatter"
require "footnotes_section_heading_renderer"
require "gds_api/gov_uk_delivery"
require "gds_api/rummager"
require "gds_api_proxy"
require "manual_database_exporter"
require "marshallers/document_association_marshaller"
require "marshallers/manual_publish_task_association_marshaller"
require "medical_safety_alert_indexable_formatter"
require "null_finder_schema"
require "panopticon_registerer"
require "rendered_specialist_document"
require "rummager_indexer"
require "markdown_attachment_processor"
require "specialist_document_database_exporter"
require "govspeak_to_html_renderer"
require "specialist_document_header_extractor"
require "specialist_document_repository"
require "repository_registry"
require "entity_factory_registry"
require "validatable_entity_factory_registry"
require "view_adapter_registry"

$LOAD_PATH.unshift(File.expand_path("../..", "app/services"))

SpecialistPublisherWiring = DependencyContainer.new do
  define_factory(:manual_builder) {
    ManualBuilder.new(
      slug_generator: SlugGenerator.new(prefix: "guidance"),
      factory: get(:validatable_manual_with_sections_factory),
    )
  }

  define_factory(:validatable_manual_with_sections_factory) {
    ->(attrs) {
      ManualValidator.new(
        NullValidator.new(
          get(:manual_with_sections_factory).call(attrs),
        ),
      )
    }
  }

  define_factory(:manual_document_builder) {
    get(:validatable_entity_factories).manual_document_builder
  }

  define_factory(:manual_with_sections_factory) {
    ->(attrs) {
      ManualWithDocuments.new(
        get(:manual_document_builder),
        Manual.new(attrs),
        documents: [],
      )
    }
  }

  define_factory(:view_adapter_registry) {
    ViewAdapterRegistry.new
  }

  define_factory(:repository_registry) {
    RepositoryRegistry.new(
      entity_factories: get(:validatable_entity_factories),
    )
  }

  define_factory(:validatable_entity_factories) {
    ValidatableEntityFactoryRegistry.new(get(:entity_factories))
  }

  define_factory(:entity_factories) {
    EntityFactoryRegistry.new
  }

  define_factory(:organisational_manual_repository_factory) {
    get(:repository_registry).method(:organisation_scoped_manual_repository)
  }

  define_singleton(:edition_factory) { SpecialistDocumentEdition.method(:new) }

  define_factory(:cma_case_builder) {
    SpecialistDocumentBuilder.new("cma_case",
      get(:validatable_entity_factories).cma_case_factory)
  }

  define_factory(:aaib_report_builder) {
    SpecialistDocumentBuilder.new("aaib_report",
      get(:validatable_entity_factories).aaib_report_factory)
  }

  define_factory(:drug_safety_update_builder) {
    SpecialistDocumentBuilder.new("drug_safety_update",
      get(:validatable_entity_factories).drug_safety_update_factory)
  }

  define_factory(:maib_report_builder) {
    SpecialistDocumentBuilder.new("maib_report",
      get(:validatable_entity_factories).maib_report_factory)
  }

  define_factory(:medical_safety_alert_builder) {
    SpecialistDocumentBuilder.new("medical_safety_alert",
      get(:validatable_entity_factories).medical_safety_alert_factory)
  }

  define_factory(:international_development_fund_builder) {
    SpecialistDocumentBuilder.new("international_development_fund",
      get(:validatable_entity_factories).international_development_fund_factory)
  }

  define_factory(:raib_report_builder) {
    SpecialistDocumentBuilder.new("raib_report",
      get(:validatable_entity_factories).raib_report_factory)
  }

  define_factory(:manual_publish_task_builder) {
    ManualPublishTaskBuilder.new(
      collection: ManualPublishTask,
    )
  }

  define_instance(:markdown_attachment_renderer) {
    MarkdownAttachmentProcessor.method(:new)
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

  define_instance(:footnotes_section_heading_renderer) {
    ->(doc) {
      FootnotesSectionHeadingRenderer.new(doc)
    }
  }

  define_instance(:govspeak_to_html_renderer) {
    ->(doc) {
      GovspeakToHTMLRenderer.new(
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

  define_factory(:international_development_fund_header_depth_limiter) {
    ->(doc) {
      DocumentHeadersDepthLimiter.new(doc, depth: 2)
    }
  }

  define_instance(:manual_renderer) {
    ->(manual) {
      get(:govspeak_to_html_renderer).call(manual)
    }
  }

  define_instance(:specialist_document_renderer) {
    ->(doc) {
      pipeline = [
        get(:markdown_attachment_renderer),
        get(:specialist_document_govspeak_header_extractor),
        get(:govspeak_to_html_renderer),
      ]

      pipeline.reduce(doc) { |doc, next_renderer|
        next_renderer.call(doc)
      }
    }
  }

  define_instance(:international_development_fund_renderer) {
    ->(doc) {
      pipeline = [
        get(:markdown_attachment_renderer),
        get(:specialist_document_govspeak_header_extractor),
        get(:international_development_fund_header_depth_limiter),
        get(:govspeak_to_html_renderer),
      ]

      pipeline.reduce(doc) { |doc, next_renderer|
        next_renderer.call(doc)
      }
    }
  }

  define_instance(:manual_document_renderer) {
    ->(doc) {
      pipeline = [
        get(:markdown_attachment_renderer),
        get(:specialist_document_govspeak_header_extractor),
        get(:govspeak_to_html_renderer),
        get(:footnotes_section_heading_renderer),
      ]

      pipeline.reduce(doc) { |doc, next_renderer|
        next_renderer.call(doc)
      }
    }
  }

  define_factory(:panopticon_registerer) {
    ->(artefact) {
      PanopticonRegisterer.new(
        artefact: artefact,
        api: get(:panopticon_api),
        error_logger: Airbrake.method(:notify),
      ).call
    }
  }

  define_factory(:panopticon_api) {
    GdsApiProxy.new(
      GdsApi::Panopticon.new(
        Plek.current.find("panopticon"),
        PANOPTICON_API_CREDENTIALS
      )
    )
  }

  define_factory(:aaib_report_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        AaibReportArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:cma_case_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        CmaCaseArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:drug_safety_update_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        DrugSafetyUpdateArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:maib_report_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        MaibReportArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:medical_safety_alert_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        MedicalSafetyAlertArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:international_development_fund_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        InternationalDevelopmentFundArtefactFormatter.new(document)
      )
    }
  }

  define_factory(:raib_report_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        RaibReportArtefactFormatter.new(document)
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
    }
  }

  define_factory(:aaib_report_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        AaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:aaib_report_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        AaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:cma_case_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        CmaCaseIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:cma_case_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        CmaCaseIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:drug_safety_update_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        DrugSafetyUpdateIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:maib_report_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        MaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:maib_report_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        MaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:medical_safety_alert_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        MedicalSafetyAlertIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:drug_safety_update_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        DrugSafetyUpdateIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:medical_safety_alert_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        MedicalSafetyAlertIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:international_development_fund_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        InternationalDevelopmentFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:international_development_fund_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        InternationalDevelopmentFundIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:raib_report_rummager_indexer) {
    ->(document) {
      RummagerIndexer.new.add(
        RaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:raib_report_rummager_deleter) {
    ->(document) {
      RummagerIndexer.new.delete(
        RaibReportIndexableFormatter.new(
          MarkdownAttachmentProcessor.new(document)
        )
      )
    }
  }

  define_factory(:specialist_document_content_api_withdrawer) {
    ->(document) {
      RenderedSpecialistDocument.where(slug: document.slug).map(&:destroy)
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

  define_instance(:maib_report_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:maib_report_finder_schema),
        doc,
      ).call
    }
  }

  define_instance(:medical_safety_alert_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:medical_safety_alert_finder_schema),
        doc,
      ).call
    }
  }

  define_instance(:drug_safety_update_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:drug_safety_update_finder_schema),
        doc,
      ).call
    }
  }

  define_instance(:international_development_fund_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:international_development_fund_renderer),
        get(:international_development_fund_finder_schema),
        doc,
      ).call
    }
  }

  define_instance(:raib_report_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:raib_report_finder_schema),
        doc,
      ).call
    }
  }

  define_singleton(:rummager_api) {
    GdsApi::Rummager.new(Plek.new.find("search"))
  }

  define_singleton(:delivery_api) {
    GdsApi::GovUkDelivery.new(Plek.current.find("govuk-delivery"))
  }

  define_singleton(:aaib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/aaib-reports.json"))
  }

  define_singleton(:cma_case_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/cma-cases.json"))
  }

  define_singleton(:drug_safety_update_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/drug-safety-updates.json"))
  }

  define_singleton(:maib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/maib-reports.json"))
  }

  define_singleton(:medical_safety_alert_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/medical-safety-alerts.json"))
  }

  define_singleton(:international_development_fund_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/international-development-funds.json"))
  }

  define_singleton(:raib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("schemas/raib-reports.json"))
  }
end
