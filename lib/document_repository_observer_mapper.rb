class DocumentRepositoryObserverMapper
  def initialize(mapping = nil)
    mapping ||= repository_listeners_map
    @mapping = mapping
  end

  def repository_listeners(subset = nil)
    return mapping.values if subset.nil?
    [mapping.fetch(subset)]
  end

private
  attr_reader :mapping

  def repository_listeners_map
    {
      "cma_case" => RepositoryObserversTuple.new(
        wiring(:cma_case_repository),
        CmaCaseObserversRegistry.new.republication,
      ),
      "aaib_report" => RepositoryObserversTuple.new(
        wiring(:aaib_report_repository),
        AaibReportObserversRegistry.new.republication,
      ),
      "international_development_fund" => RepositoryObserversTuple.new(
        wiring(:international_development_fund_repository),
        InternationalDevelopmentFundObserversRegistry.new.republication,
      ),
      "medical_safety_alert" => RepositoryObserversTuple.new(
        wiring(:medical_safety_alert_repository),
        MedicalSafetyAlertObserversRegistry.new.republication,
      ),
      "drug_safety_update" => RepositoryObserversTuple.new(
        wiring(:drug_safety_update_repository),
        DrugSafetyUpdateObserversRegistry.new.republication,
      ),
    }
  end

  def wiring(key)
    SpecialistPublisherWiring.get(key)
  end

  class RepositoryObserversTuple < Struct.new(:repository, :observers); end
end
