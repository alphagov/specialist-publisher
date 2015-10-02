require "validators/aaib_report_validator"
require "validators/change_note_validator"
require "validators/cma_case_validator"
require "validators/countryside_stewardship_grant_validator"
require "validators/drug_safety_update_validator"
require "validators/esi_fund_validator"
require "validators/international_development_fund_validator"
require "validators/maib_report_validator"
require "validators/manual_document_validator"
require "validators/manual_validator"
require "validators/medical_safety_alert_validator"
require "validators/null_validator"
require "validators/raib_report_validator"
require "validators/vehicle_recalls_and_faults_alert_validator"
require "validators/asylum_support_decision_validator"
require "validators/utaac_decision_validator"
require "validators/tax_tribunal_decision_validator"

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
require "asylum_support_decision"
require "utaac_decision"
require "tax_tribunal_decision"

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

  def countryside_stewardship_grant_factory
    ->(*args) {
      ChangeNoteValidator.new(
        CountrysideStewardshipGrantValidator.new(
          CountrysideStewardshipGrant.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "countryside-stewardship-grants"),
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

  def esi_fund_factory
    ->(*args) {
      ChangeNoteValidator.new(
        EsiFundValidator.new(
          EsiFund.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "european-structural-investment-funds"),
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

  def vehicle_recalls_and_faults_alert_factory
    ->(*args) {
      ChangeNoteValidator.new(
        VehicleRecallsAndFaultsAlertValidator.new(
          VehicleRecallsAndFaultsAlert.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "vehicle-recalls-faults"),
              *args,
            )
          )
        )
      )
    }
  end

  def asylum_support_decision_factory
    ->(*args) {
      ChangeNoteValidator.new(
        AsylumSupportDecisionValidator.new(
          AsylumSupportDecision.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "asylum-support-decisions"),
              *args,
            ),
          )
        )
      )
    }
  end

  def utaac_decision_factory
    ->(*args) {
      ChangeNoteValidator.new(
        UtaacDecisionValidator.new(
          UtaacDecision.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "utaac-decisions"),
              *args,
            ),
          )
        )
      )
    }
  end

  def tax_tribunal_decision_factory
    ->(*args) {
      ChangeNoteValidator.new(
        TaxTribunalDecisionValidator.new(
          TaxTribunalDecision.new(
            SpecialistDocument.new(
              SlugGenerator.new(prefix: "tax-and-chancery-tribunal-decisions"),
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
