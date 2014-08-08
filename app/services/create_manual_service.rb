class CreateManualService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @manual_builder = dependencies.fetch(:manual_builder)
    @listeners = dependencies.fetch(:listeners)
    @context = dependencies.fetch(:context)
  end

  def call
    if manual.valid?
      persist
      notify_listeners
    end

    manual
  end

  private

  attr_reader :manual_repository, :manual_builder, :listeners, :context

  def manual
    @manual ||= manual_builder.call(manual_params)
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(manual)
    end
  end

  def manual_params
    context.params
      .fetch("manual")
      .slice(*valid_params)
      .merge(
        organisation_slug: organisation_slug,
      )
      .symbolize_keys
  end

  def valid_params
    %i(
      title
      summary
    )
  end

  def organisation_slug
    context.current_organisation_slug
  end
end
