class OrganisationalManualServiceRegistry
  def initialize(dependencies)
    @organisation_slug = dependencies.fetch(:organisation_slug)
  end

  def list(context)
    ListManualsService.new(
      manual_repository: manual_repository,
      context: context,
    )
  end

  def create(context)
    CreateManualService.new(
      manual_repository: manual_repository,
      manual_builder: manual_builder,
      listeners: observers.creation,
      context: context,
    )
  end

  def update(context)
    UpdateManualService.new(
      manual_repository: manual_repository,
      context: context,
    )
  end

  def show(context)
    ShowManualService.new(
      manual_repository: manual_repository,
      context: context,
    )
  end

  def publish(manual_id)
    PublishManualService.new(
      manual_repository: manual_repository,
      listeners: observers.publication,
      context: context,
    )
  end

private
  attr_reader :organisation_slug

  def manual_builder
    # TODO Use ManualBuilder.new instead
    SpecialistPublisherWiring.get(:manual_builder)
  end

  def manual_repository
    # TODO Get this from a RepositoryRegistry
    SpecialistPublisherWiring
      .get(:organisational_manual_repository_factory)
      .call(organisation_slug)
  end

  def observers
    @observers ||= ManualObserversRegistry.new
  end
end
