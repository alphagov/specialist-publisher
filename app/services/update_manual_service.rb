class UpdateManualService
  def initialize(dependencies)
    @manual_repository = dependencies.fetch(:manual_repository)
    @context = dependencies.fetch(:context)
  end

  def call
    update
    persist

    manual
  end

  private

  attr_reader :manual_repository, :context

  def update
    manual.update(manual_params)
  end

  def persist
    manual_repository.store(manual)
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
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

  def manual_id
    context.params.fetch("id")
  end
end
