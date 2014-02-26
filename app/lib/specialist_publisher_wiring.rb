require 'dependency_container'

SpecialistPublisherWiring = DependencyContainer.new do
  define_instance(:specialist_document_editions) { SpecialistDocumentEdition }
  define_instance(:artefacts) { Artefact }
  define_instance(:panopticon_mappings) { PanopticonMapping }
  define_singleton(:panopticon_api) do
    GdsApi::Panopticon.new(Plek.current.find("panopticon"), PANOPTICON_API_CREDENTIALS)
  end
  define_singleton(:specialist_document_factory) { SpecialistDocument.method(:new) }
  define_singleton(:specialist_document_registry) do
    build_with_dependencies(SpecialistDocumentRegistry)
  end
end
