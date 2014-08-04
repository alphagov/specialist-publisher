class ManualDocumentObserversRegistry
  def creation
    []
  end

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:manual_document_panopticon_registerer)
  end
end
