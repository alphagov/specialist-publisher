class ShowManualService

  def initialize(dependencies = {})
    @manual_id = dependencies.fetch(:manual_id)
    @manual_repository = dependencies.fetch(:manual_repository)
  end

  def call
    [
      manual_repository.fetch(manual_id),
      other_metadata,
    ]
  end

private

  attr_reader(
    :manual_id,
    :manual_repository,
  )

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def other_metadata
    {
      slug_unique: slug_unique?,
    }
  end

  def slug_unique?
    manual_repository.slug_unique?(manual)
  end
end
