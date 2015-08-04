class CreateManualService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @manual_builder = dependencies.fetch(:manual_builder)
    @listeners = dependencies.fetch(:listeners)
    @attributes = dependencies.fetch(:attributes)
  end

  def call
    if manual.valid?
      persist
      notify_listeners
    end

    manual
  end

  private

  attr_reader(
    :manual_repository,
    :manual_builder,
    :listeners,
    :attributes,
  )

  def manual
    @manual ||= manual_builder.call(attributes)
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    reloaded_manual = manual_repository[manual.id]
    listeners.each do |listener|
      listener.call(reloaded_manual)
    end
  end
end
