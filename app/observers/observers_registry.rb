class ObserversRegistry

  def initialize(dependencies)
    @document_content_api_exporter = dependencies.fetch(:document_content_api_exporter)
    @finder_api_notifier = dependencies.fetch(:finder_api_notifier)
    @panopticon_registerer = dependencies.fetch(:panopticon_registerer)
  end

  def document_publication
    [
      document_content_api_exporter,
      finder_api_notifier,
      panopticon_registerer,
    ]
  end

  def manual_publication
    []
  end


  private

  attr_reader(
    :document_content_api_exporter,
    :finder_api_notifier,
    :panopticon_registerer,
  )

end
