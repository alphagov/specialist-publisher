class UpdateManualService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @manual_id = dependencies.fetch(:manual_id)
    @attributes = dependencies.fetch(:attributes)
  end

  def call
    update
    persist

    manual
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
    :attributes,
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

end
