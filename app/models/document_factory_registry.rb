require "validators/aaib_report_validator"
require "validators/change_note_validator"
require "validators/cma_case_validator"
require "validators/drug_safety_update_validator"
require "validators/international_development_fund_validator"
require "validators/maib_report_validator"
require "validators/manual_document_validator"
require "validators/manual_validator"
require "validators/medical_safety_alert_validator"
require "validators/null_validator"
require "validators/raib_report_validator"

require "builders/manual_document_builder"
require "manual_with_documents"
require "slug_generator"
require "specialist_document"

require "slug_generator"
require "specialist_document"
require "aaib_report"
require "cma_case"
require "drug_safety_update"
require "medical_safety_alert"
require "international_development_fund"

class DocumentFactoryRegistry
  def aaib_report_factory
    ->(*args) {
      ChangeNoteValidator.new(
        AaibReportValidator.new(
          AaibReport.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "aaib-reports"),
              *args,
            ),
          )
        )
      )
    }
  end

  def cma_case_factory
    ->(*args) {
      ChangeNoteValidator.new(
        CmaCaseValidator.new(
          CmaCase.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "cma-cases"),
              *args,
            ),
          )
        )
      )
    }
  end

  def drug_safety_update_factory
    ->(*args) {
      ChangeNoteValidator.new(
        DrugSafetyUpdateValidator.new(
          DrugSafetyUpdate.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "drug-safety-update"),
              *args,
            )
          )
        )
      )
    }
  end

  def maib_report_factory
    ->(*args) {
      ChangeNoteValidator.new(
        MaibReportValidator.new(
          MaibReport.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "maib-reports"),
              *args,
            ),
          )
        )
      )
    }
  end

  def medical_safety_alert_factory
    ->(*args) {
      ChangeNoteValidator.new(
        MedicalSafetyAlertValidator.new(
          MedicalSafetyAlert.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "drug-device-alerts"),
              *args,
            )
          )
        )
      )
    }
  end

  def international_development_fund_factory
    ->(*args) {
      ChangeNoteValidator.new(
        InternationalDevelopmentFundValidator.new(
          InternationalDevelopmentFund.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "international-development-funding"),
              *args,
            ),
          )
        )
      )
    }
  end

  def raib_report_factory
    ->(*args) {
      ChangeNoteValidator.new(
        RaibReportValidator.new(
          RaibReport.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "raib-reports"),
              *args,
            ),
          )
        )
      )
    }
  end

  def manual_with_documents
    ->(manual, attrs) {
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
    ManualDocumentBuilder.new(factory_factory: manual_document_factory_factory)
  end

  def manual_document_factory_factory
    ->(manual) {
      ->(id, editions) {
        slug_generator = SlugGenerator.new(prefix: manual.slug)

        ChangeNoteValidator.new(
          ManualDocumentValidator.new(
            SpecialistDocument.new(
              slug_generator,
              id,
              editions,
            ),
          )
        )
      }
    }
  end
end
