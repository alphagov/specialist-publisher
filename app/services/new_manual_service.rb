class NewManualService
  def initialize(dependencies)
    @manual_builder = dependencies.fetch(:manual_builder)
    @context = dependencies.fetch(:context)
  end

  def call
    manual_builder.call(initial_params)
  end

  private

  attr_reader :manual_builder, :context

  def initial_params
    {}
  end
end
