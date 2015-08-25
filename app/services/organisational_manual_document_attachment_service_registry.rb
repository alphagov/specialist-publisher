class OrganisationalManualDocumentAttachmentServiceRegistry < AbstractManualDocumentAttachmentServiceRegistry
  def initialize(dependencies)
    @organisation_slug = dependencies.fetch(:organisation_slug)
  end

private
  attr_reader :organisation_slug

  def manual_repository_factory
    SpecialistPublisherWiring.get(:repository_registry)
      .organisation_scoped_manual_repository_factory
  end

  def repository
    manual_repository_factory.call(organisation_slug)
  end
end
