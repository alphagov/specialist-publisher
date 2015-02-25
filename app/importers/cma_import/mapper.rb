class CmaImportAttributeMapper
  def initialize(create_document_service)
    @create_document_service = create_document_service
  end

  def call(data)
    create_document_service.call(
      attributes(data)
    )
  end

private
  attr_reader :create_document_service

  def attributes(data)
    data
      .slice(*attribute_keys)
      .symbolize_keys
  end

  def attribute_keys
    %w(
      title
      summary
      body

      opened_date
      closed_date
      case_type
      case_state
      market_sector
      outcome_type
    )
  end
end
