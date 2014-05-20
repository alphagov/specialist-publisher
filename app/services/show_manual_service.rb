class ShowManualService

  def initialize(dependencies = {})
    @manual_repository = dependencies.fetch(:manual_repository)
    @context = dependencies.fetch(:context)
  end

  def call
    manual_repository.fetch(manual_id)
  end

  private

  attr_reader :manual_repository, :context

  def manual_id
    context.params.fetch("id")
  end
end
