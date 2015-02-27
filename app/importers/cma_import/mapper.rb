class CmaImportAttributeMapper
  def initialize(create_document_service)
    @create_document_service = create_document_service
  end

  def call(data)
    document = create_document_service.call(
      attributes(data)
    )

    Presenter.new(
      document,
      data,
    )
  end

private
  attr_reader :create_document_service

  def attributes(data)
    data
      .slice(*attribute_keys)
      .symbolize_keys
      .merge(
        body: data.fetch("body", ""),
      )
  end

  def attribute_keys
    %w(
      title
      summary

      opened_date
      closed_date
      case_type
      case_state
      market_sector
      outcome_type
    )
  end

  def body_defined?(data)
    data.has_key?("body")
  end

  class Presenter < SimpleDelegator
    def initialize(document, data)
      @data = data

      super(document)
    end

    def import_notes
      super.concat(messages)
    end

  private
    attr_reader :data

    def messages
      [
        body_missing_message,
      ].compact
    end

    def body_missing_message
      "`body` field not defined" unless data.has_key?("body")
    end
  end
end
