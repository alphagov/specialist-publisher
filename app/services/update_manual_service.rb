class UpdateManualService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @manual_id = dependencies.fetch(:manual_id)
    @attributes = dependencies.fetch(:attributes)
    @listeners = dependencies.fetch(:listeners)
  end

  def call
    update
    persist
    notify_listeners

    manual
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
    :attributes,
    :listeners,
  )

  def update
    manual.update(attributes)
  end

  def persist
    manual_repository.store(manual)
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def notify_listeners
    reloaded_manual = manual_repository[manual.id]
    listeners.each do |listener|
      listener.call(reloaded_manual)
    end
  end
end
