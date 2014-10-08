require "slug_generator"
require "specialist_document"
require "aaib_report"
require "cma_case"
require "drug_safety_update"
require "medical_safety_alert"
require "international_development_fund"

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
    ->(*args) {
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
    ->(*args) {
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
    ->(*args) {
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
