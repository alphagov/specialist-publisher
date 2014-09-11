class PreviewManualService
  def initialize(dependencies = {})
    @repository = dependencies.fetch(:repository)
    @builder = dependencies.fetch(:builder)
    @renderer = dependencies.fetch(:renderer)
    @manual_id = dependencies.fetch(:manual_id)
    @attributes = dependencies.fetch(:attributes)
  end

  def call
    manual.update(attributes)

    renderer.call(manual)
  end

  private

  attr_reader(
    :repository,
    :builder,
    :renderer,
    :manual_id,
    :attributes,
  )

  def manual
    manual_id ? existing_manual : ephemeral_manual
  end

  def ephemeral_manual
    builder.call(
      attributes.reverse_merge(
        title: ""
      )
    )
  end

  def existing_manual
    @existing_manual ||= repository.fetch(manual_id)
  end
end
