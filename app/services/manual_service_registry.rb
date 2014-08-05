class ManualServiceRegistry
  def publish(manual_id)
    PublishManualService.new(
      manual_repository: manual_repository,
      listeners: observers.publication,
      manual_id: manual_id,
    )
  end

private
  def manual_repository
    # TODO Get this from a RepositoryRegistry
    SpecialistPublisherWiring.get(:manual_repository)
  end

  def observers
    @observers ||= ManualObserversRegistry.new
  end
end
