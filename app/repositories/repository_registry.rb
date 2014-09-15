class RepositoryRegistry
  def initialize(entity_factories:)
    @entity_factories = entity_factories
  end

  def aaib_report_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "aaib_report"),
      document_factory: entity_factories.aaib_report_factory,
    )
  end

  def cma_case_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "cma_case"),
      document_factory: entity_factories.cma_case_factory,
    )
  end

  def drug_safety_update_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "drug_safety_update"),
      document_factory: entity_factories.drug_safety_update_factory,
    )
  end

  def medical_safety_alert_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "medical_safety_alert"),
      document_factory: entity_factories.medical_safety_alert_factory,
    )
  end

  def international_development_fund_repository
    SpecialistDocumentRepository.new(
      specialist_document_editions: SpecialistDocumentEdition.where(document_type: "international_development_fund"),
      document_factory: entity_factories.international_development_fund_factory,
    )
  end

  def organisation_scoped_manual_repository(organisation_slug)
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
      collection: ManualRecord.where(organisation_slug: organisation_slug),
    )
  end

  def manual_specific_document_repository_factory
    ->(manual) {
      document_factory = entity_factories.manual_document_factory_factory.call(manual)

      SpecialistDocumentRepository.new(
        specialist_document_editions: SpecialistDocumentEdition.where(document_type: "manual"),
        document_factory: document_factory,
      )
    }
  end

private

  attr_reader :entity_factories

  def scoped_editions(document_type)
    # TODO
  end
end

class EntityFactoryRegistry
  def aaib_report_factory
    ->(*args) {
      AaibReport.new(
        SpecialistDocument.new(
          SlugGenerator.new(prefix: "aaib-reports"),
          edition_factory,
          *args,
        ),
      )
    }
  end

  def cma_case_factory
    ->(*args){
      CmaCase.new(
        SpecialistDocument.new(
          SlugGenerator.new(prefix: "cma-cases"),
          edition_factory,
          *args,
        ),
      )
    }
  end

  def drug_safety_update_factory
    ->(*args){
      DrugSafetyUpdate.new(
        SpecialistDocument.new(
          SlugGenerator.new(prefix: "drug-safety-update"),
          edition_factory,
          *args,
        )
      )
    }
  end

  def medical_safety_alert_factory
    ->(*args) {
      MedicalSafetyAlert.new(
        SpecialistDocument.new(
          SlugGenerator.new(prefix: "drug-device-alerts"),
          edition_factory,
          *args,
        )
      )
    }
  end

  def international_development_fund_factory
    ->(*args){
      InternationalDevelopmentFund.new(
        SpecialistDocument.new(
          SlugGenerator.new(prefix: "international-development-funding"),
          edition_factory,
          *args,
        ),
      )
    }
  end

  def edition_factory
    SpecialistDocumentEdition.method(:new)
  end
end

class ValidatableEntityFactoryRegistry
  def initialize(entity_factory_registry)
    @entity_factory_registry = entity_factory_registry
  end

  def aaib_report_factory
    ->(*args) {
      AaibReportValidator.new(
        entity_factory_registry.aaib_report_factory.call(*args),
      )
    }
  end

  def cma_case_factory
    ->(*args) {
      CmaCaseValidator.new(
        entity_factory_registry.cma_case_factory.call(*args),
      )
    }
  end

  def drug_safety_update_factory
    ->(*args){
      DrugSafetyUpdateValidator.new(
        entity_factory_registry.drug_safety_update_factory.call(*args),
      )
    }
  end

  def medical_safety_alert_factory
    ->(*args){
      MedicalSafetyAlertValidator.new(
        entity_factory_registry.medical_safety_alert_factory.call(*args),
      )
    }
  end

  def international_development_fund_factory
    ->(*args){
      InternationalDevelopmentFundValidator.new(
        entity_factory_registry.international_development_fund_factory.call(*args),
      )
    }
  end

  def manual_with_documents
    ->(manual, attrs){
      ManualValidator.new(
        NullValidator.new(
          ManualWithDocuments.new(
            manual_document_builder,
            manual,
            attrs,
          )
        )
      )
    }
  end

  def manual_document_builder
    ManualDocumentBuilder.new(
      factory_factory: manual_document_factory_factory,
      id_generator: IdGenerator,
    )
  end


  def manual_document_factory_factory
    ->(manual) {
      ->(id, editions) {
        slug_generator = SlugGenerator.new(prefix: manual.slug)

        ChangeNoteValidator.new(
          ManualDocumentValidator.new(
            SpecialistDocument.new(
              slug_generator,
              entity_factory_registry.edition_factory,
              id,
              editions,
            ),
          )
        )
      }
    }
  end

private

  attr_reader :entity_factory_registry
    ->(manual) {
      document_factory = get(:validated_manual_document_factory_factory).call(manual)

      SpecialistDocumentRepository.new(
        specialist_document_editions: SpecialistDocumentEdition.where(document_type: "manual"),
        document_factory: document_factory,
      )
    }
end
