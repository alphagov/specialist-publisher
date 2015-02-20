require "builders/manual_builder"
require "builders/manual_document_builder"
require "builders/specialist_document_builder"
require "dependency_container"
require "document_factory_registry"
require "document_headers_depth_limiter"
require "footnotes_section_heading_renderer"
require "formatters/aaib_report_artefact_formatter"
require "formatters/cma_case_artefact_formatter"
require "formatters/countryside_stewardship_grant_artefact_formatter"
require "formatters/drug_safety_update_artefact_formatter"
require "formatters/esi_fund_artefact_formatter"
require "formatters/international_development_fund_artefact_formatter"
require "formatters/maib_report_artefact_formatter"
require "formatters/medical_safety_alert_artefact_formatter"
require "formatters/raib_report_artefact_formatter"
require "gds_api/email_alert_api"
require "gds_api/rummager"
require "gds_api_proxy"
require "govspeak_to_html_renderer"
require "markdown_attachment_processor"
require "marshallers/document_association_marshaller"
require "marshallers/manual_publish_task_association_marshaller"
require "null_finder_schema"
require "panopticon_registerer"
require "rendered_specialist_document"
require "repository_registry"
require "specialist_document_database_exporter"
require "specialist_document_header_extractor"
require "specialist_document_repository"
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
    get(:validatable_document_factories).manual_document_builder
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
      entity_factories: get(:validatable_document_factories),
    )
  }

  define_factory(:validatable_document_factories) {
    DocumentFactoryRegistry.new
  }

  define_factory(:organisational_manual_repository_factory) {
    get(:repository_registry).method(:organisation_scoped_manual_repository)
  }

  define_singleton(:edition_factory) { SpecialistDocumentEdition.method(:new) }

  define_factory(:cma_case_builder) {
    SpecialistDocumentBuilder.new("cma_case",
      get(:validatable_document_factories).cma_case_factory)
  }

  define_factory(:aaib_report_builder) {
    SpecialistDocumentBuilder.new("aaib_report",
      get(:validatable_document_factories).aaib_report_factory)
  }

  define_factory(:countryside_stewardship_grant_builder) {
    SpecialistDocumentBuilder.new("countryside_stewardship_grant",
    get(:validatable_document_factories).countryside_stewardship_grant_factory)
  }

  define_factory(:drug_safety_update_builder) {
    SpecialistDocumentBuilder.new("drug_safety_update",
      get(:validatable_document_factories).drug_safety_update_factory)
  }

  define_factory(:esi_fund_builder) {
    SpecialistDocumentBuilder.new("esi_fund",
      get(:validatable_document_factories).esi_fund_factory)
  }

  define_factory(:maib_report_builder) {
    SpecialistDocumentBuilder.new("maib_report",
      get(:validatable_document_factories).maib_report_factory)
  }

  define_factory(:medical_safety_alert_builder) {
    SpecialistDocumentBuilder.new("medical_safety_alert",
      get(:validatable_document_factories).medical_safety_alert_factory)
  }

  define_factory(:international_development_fund_builder) {
    SpecialistDocumentBuilder.new("international_development_fund",
      get(:validatable_document_factories).international_development_fund_factory)
  }

  define_factory(:raib_report_builder) {
    SpecialistDocumentBuilder.new("raib_report",
      get(:validatable_document_factories).raib_report_factory)
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

  define_factory(:countryside_stewardship_grant_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        CountrysideStewardshipGrantArtefactFormatter.new(document)
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

  define_factory(:esi_fund_panopticon_registerer) {
    ->(document) {
      get(:panopticon_registerer).call(
        EsiFundArtefactFormatter.new(document)
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
        PublicationLog,
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
        PublicationLog,
      ).call
    }
  }

  define_instance(:countryside_stewardship_grant_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:countryside_stewardship_grant_finder_schema),
        doc,
        PublicationLog,
      ).call
    }
  }

  define_instance(:esi_fund_content_api_exporter) {
    ->(doc) {
      SpecialistDocumentDatabaseExporter.new(
        RenderedSpecialistDocument,
        get(:specialist_document_renderer),
        get(:esi_fund_finder_schema),
        doc,
        PublicationLog,
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
        PublicationLog,
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
        PublicationLog,
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
        PublicationLog,
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
        PublicationLog,
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
        PublicationLog,
      ).call
    }
  }

  define_singleton(:rummager_api) {
    GdsApi::Rummager.new(Plek.new.find("search"))
  }

  define_singleton(:email_alert_api) {
    GdsApi::EmailAlertApi.new(Plek.current.find("email-alert-api"))
  }

  define_singleton(:aaib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/aaib-reports.json"))
  }

  define_singleton(:cma_case_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/cma-cases.json"))
  }

  define_singleton(:countryside_stewardship_grant_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/countryside-stewardship-grants.json"))
  }

  define_singleton(:drug_safety_update_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/drug-safety-updates.json"))
  }

  define_singleton(:esi_fund_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/esi-funds.json"))
  }

  define_singleton(:maib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/maib-reports.json"))
  }

  define_singleton(:medical_safety_alert_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/medical-safety-alerts.json"))
  }

  define_singleton(:international_development_fund_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/international-development-funds.json"))
  }

  define_singleton(:raib_report_finder_schema) {
    require "finder_schema"
    FinderSchema.new(Rails.root.join("finders/schemas/raib-reports.json"))
  }
end
