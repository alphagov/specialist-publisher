class ObserversRegistry

  def initialize(dependencies)
    @document_content_api_exporter = dependencies.fetch(:document_content_api_exporter)
    @finder_api_notifier = dependencies.fetch(:finder_api_notifier)
    @document_panopticon_registerer = dependencies.fetch(:document_panopticon_registerer)
    @manual_panopticon_registerer = dependencies.fetch(:manual_panopticon_registerer)
    @manual_document_panopticon_registerer = dependencies.fetch(:manual_document_panopticon_registerer)
  end

  def document_publication
    [
      document_content_api_exporter,
      finder_api_notifier,
      document_panopticon_registerer,
    ]
  end

  def manual_publication
    [
      manual_panopticon_registerer,
    ]
  end

  def manual_creation
    [
      manual_panopticon_registerer,
    ]
  end

  def manual_document_creation
    [
      manual_document_panopticon_registerer,
    ]
  end


  private

  attr_reader(
    :document_content_api_exporter,
    :finder_api_notifier,
    :document_panopticon_registerer,
    :manual_panopticon_registerer,
    :manual_document_panopticon_registerer,
  )
end
