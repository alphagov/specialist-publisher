class ManualDocumentBuilder
  def initialize(factory)
    @factory = factory
  end

  def call(attrs)
    defaults.merge(attrs)

    factory.call(defaults.merge(attrs))
  end

  private

  attr_reader :factory

  def defaults
    {
      document_type: 'manual',
    }.merge(hacky_cma_defaults)
  end

  # TODO: remove the hacky CMA defaults!
  def hacky_cma_defaults
    {
      opened_date: Date.parse('1/04/2014'),
      market_sector: 'manual',
      case_type: 'manual',
      case_state: 'manual',
    }
  end
end
