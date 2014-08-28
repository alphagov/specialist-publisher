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
      "cma_cases" => RepositoryObserversTuple.new(
        wiring(:cma_case_repository),
        CmaCaseObserversRegistry.new.publication,
      ),
      "aaib_reports" => RepositoryObserversTuple.new(
        wiring(:aaib_report_repository),
        AaibReportObserversRegistry.new.publication,
      ),
      "international_development_funds" => RepositoryObserversTuple.new(
        wiring(:international_development_fund_repository),
        InternationalDevelopmentFundObserversRegistry.new.publication,
      ),
    }
  end

  def wiring(key)
    SpecialistPublisherWiring.get(key)
  end

  class RepositoryObserversTuple < Struct.new(:repository, :observers); end
end
