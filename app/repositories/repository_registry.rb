require "specialist_document_repository"
require "manual_repository"
require "specialist_document_edition"
require "marshallers/document_association_marshaller"
require "marshallers/manual_publish_task_association_marshaller"
require "manual_publish_task"
require "manual_with_publish_tasks"
require "manual"
require "manual_record"
require "specialist_document_edition"
require "specialist_document_repository"

class RepositoryRegistry
  def initialize(entity_factories:)
    @entity_factories = entity_factories
  end

  def aaib_report_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: scoped_editions("aaib_report"),
      document_factory: entity_factories.aaib_report_factory,
    )
  end

  def cma_case_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: scoped_editions("cma_case"),
      document_factory: entity_factories.cma_case_factory,
    )
  end

  def drug_safety_update_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: scoped_editions("drug_safety_update"),
      document_factory: entity_factories.drug_safety_update_factory,
    )
  end

  def medical_safety_alert_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: scoped_editions("medical_safety_alert"),
      document_factory: entity_factories.medical_safety_alert_factory,
    )
  end

  def international_development_fund_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: scoped_editions("international_development_fund"),
      document_factory: entity_factories.international_development_fund_factory,
    )
  end

  def organisation_scoped_manual_repository(organisation_slug)
    scoped_manual_repository(
      ManualRecord.where(organisation_slug: organisation_slug)
    )
  end

  def manual_repository
    scoped_manual_repository(ManualRecord.all)
  end

  def scoped_manual_repository(collection)
    ManualRepository.new(
      association_marshallers: [
        DocumentAssociationMarshaller.new(
          manual_specific_document_repository_factory: manual_specific_document_repository_factory,
          decorator: ->(manual, attrs) {
            entity_factories.manual_with_documents.call(manual, attrs)
          }
        ),
        ManualPublishTaskAssociationMarshaller.new(
          collection: ManualPublishTask,
          decorator: ->(manual, attrs) {
            ManualWithPublishTasks.new(
              manual,
              attrs,
            )
          }
        ),
      ],
      factory: Manual.method(:new),
      collection: collection,
    )
  end

  def manual_specific_document_repository_factory
    ->(manual) {
      document_factory = entity_factories.manual_document_factory_factory.call(manual)

      SpecialistDocumentRepository.new(
        specialist_document_editions: scoped_editions("manual"),
        document_factory: document_factory,
      )
    }
  end

private

  attr_reader :entity_factories

  def scoped_editions(document_type)
    SpecialistDocumentEdition.where(document_type: document_type)
  end
end
