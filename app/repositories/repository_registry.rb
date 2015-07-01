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
    SpecialistDocumentRepository.new(
      document_type: type,
      document_factory: entity_factories.public_send("#{type}_factory")
    )
  end

  def organisation_scoped_manual_repository_factory
    ->(organisation_slug) {
      scoped_manual_repository(
        ManualRecord.where(organisation_slug: organisation_slug)
      )
    }
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

  def associationless_manual_repository
    associationless_scoped_manual_repository(ManualRecord.all)
  end

  def associationless_scoped_manual_repository(collection)
    ManualRepository.new(
      factory: Manual.method(:new),
      collection: collection,
    )
  end

  def associationless_organisation_scoped_manual_repository_factory
    ->(organisation_slug) {
      associationless_scoped_manual_repository(
        ManualRecord.where(organisation_slug: organisation_slug)
      )
    }
  end

private
  attr_reader :entity_factories
end
