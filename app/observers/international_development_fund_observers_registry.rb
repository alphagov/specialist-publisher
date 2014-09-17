class InternationalDevelopmentFundObserversRegistry
  def creation
    []
  end

  def update
    []
  end

  def publication
    [
      content_api_exporter,
      panopticon_exporter,
      rummager_exporter,
    ]
  end

  def withdrawal
    [
      content_api_withdrawer,
      panopticon_exporter,
      rummager_withdrawer,
    ]
  end

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:international_development_fund_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:international_development_fund_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:international_development_fund_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:international_development_fund_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end
end
