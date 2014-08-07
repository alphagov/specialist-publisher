class PublishManualService
  def initialize(dependencies)
    @manual_id = dependencies.fetch(:manual_id)
    @manual_repository = dependencies.fetch(:manual_repository)
    @listeners = dependencies.fetch(:listeners)
    @version_number = dependencies.fetch(:version_number)
  end

  def call
    if versions_match?
      publish
      persist
    end

    manual
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
    :listeners,
    :version_number,
  )

  def versions_match?
    version_number == manual.version_number
  end

  def publish
    manual.publish

    notify_listeners
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(manual)
    end
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end
end
