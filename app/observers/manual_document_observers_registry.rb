class ManualDocumentObserversRegistry
  def creation
    [
      panopticon_registerer,
    ]
  end

private
  def panopticon_registerer
    SpecialistPublisherWiring.get(:manual_document_panopticon_registerer)
  end
end
