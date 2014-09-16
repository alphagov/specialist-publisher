class ManualServiceRegistry
  def publish(manual_id, version_number)
    PublishManualService.new(
      manual_repository: manual_repository,
      listeners: observers.publication,
      manual_id: manual_id,
      version_number: version_number,
    )
  end

private
  def manual_repository
    # TODO Get this from a RepositoryRegistry
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end

  def observers
    @observers ||= ManualObserversRegistry.new
  end
end
