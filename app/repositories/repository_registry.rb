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

  def for_type(type)
    public_send("#{type}_repository")
  end

  def aaib_report_repository
    SpecialistDocumentRepository.new(
      document_type: "aaib_report",
      document_factory: entity_factories.aaib_report_factory,
    )
  end

  def cma_case_repository
    SpecialistDocumentRepository.new(
      document_type: "cma_case",
      document_factory: entity_factories.cma_case_factory,
    )
  end

  def drug_safety_update_repository
    SpecialistDocumentRepository.new(
      document_type: "drug_safety_update",
      document_factory: entity_factories.drug_safety_update_factory,
    )
  end

  def maib_report_repository
    SpecialistDocumentRepository.new(
      document_type: "maib_report",
      document_factory: entity_factories.maib_report_factory,
    )
  end

  def medical_safety_alert_repository
    SpecialistDocumentRepository.new(
      document_type: "medical_safety_alert",
      document_factory: entity_factories.medical_safety_alert_factory,
    )
  end

  def international_development_fund_repository
    SpecialistDocumentRepository.new(
      document_type: "international_development_fund",
      document_factory: entity_factories.international_development_fund_factory,
    )
  end

  def raib_report_repository
    SpecialistDocumentRepository.new(
      document_type: "raib_report",
      document_factory: entity_factories.raib_report_factory,
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
        document_type: "manual",
        document_factory: document_factory,
      )
    }
  end

private
  attr_reader :entity_factories
end
