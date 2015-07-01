class ManualServiceRegistry
  def list(context)
    ListManualsService.new(
      manual_repository: manual_repository,
      context: context,
    )
  end

  def new(context)
    ->() { manual_builder.call(title: "") }
  end

  def create(attributes)
    CreateManualService.new(
      manual_repository: manual_repository,
      manual_builder: manual_builder,
      listeners: observers.creation,
      attributes: attributes,
    )
  end

  def update(manual_id, attributes)
    UpdateManualService.new(
      manual_repository: manual_repository,
      manual_id: manual_id,
      attributes: attributes,
    )
  end

  def show(manual_id)
    ShowManualService.new(
      manual_repository: manual_repository,
      manual_id: manual_id,
    )
  end

  def queue_publish(manual_id)
    QueuePublishManualService.new(
      PublishManualWorker,
      manual_repository,
      manual_id,
    )
  end

  def preview(manual_id, attributes)
    PreviewManualService.new(
      repository: manual_repository,
      builder: manual_builder,
      renderer: manual_renderer,
      manual_id: manual_id,
      attributes: attributes,
    )
  end

  def publish(manual_id, version_number)
    PublishManualService.new(
      manual_repository: manual_repository,
      listeners: observers.publication,
      manual_id: manual_id,
      version_number: version_number,
    )
  end

  def republish(manual_id)
    RepublishManualService.new(
      manual_repository: manual_repository,
      listeners: observers.republication,
      manual_id: manual_id,
    )
  end

  def withdraw(manual_id)
    WithdrawManualService.new(
      manual_repository: manual_repository,
      listeners: observers.withdrawal,
      manual_id: manual_id,
    )
  end

private
  def manual_renderer
    SpecialistPublisherWiring.get(:manual_renderer)
  end

  def manual_builder
    SpecialistPublisherWiring.get(:manual_builder)
  end

  def manual_repository
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end

  def observers
    @observers ||= ManualObserversRegistry.new
  end
end
