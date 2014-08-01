class ManualDocumentObserversRegistry
  def creation
    [
      panopticon_exporter,
    ]
  end

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:manual_document_panopticon_registerer)
  end
end
