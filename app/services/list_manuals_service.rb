class ListManualsService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @context = dependencies.fetch(:context)
  end

  def call
    manual_repository.all
  end

  private

  attr_reader :manual_repository, :context
end
