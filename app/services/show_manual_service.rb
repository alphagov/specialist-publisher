class ShowManualService

  def initialize(dependencies = {})
    @manual_id = dependencies.fetch(:manual_id)
    @manual_repository = dependencies.fetch(:manual_repository)
  end

  def call
    manual_repository.fetch(manual_id)
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
  )

end
