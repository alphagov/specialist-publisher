class ManualDocumentBuilder
  def initialize(dependencies)
    @factory_factory = dependencies.fetch(:factory_factory)
    @id_generator = dependencies.fetch(:id_generator)
  end

  def call(manual, attrs)
    @factory_factory
      .call(manual)
      .call(
        @id_generator.call,
        [],
      ).update(attrs.reverse_merge(defaults))
  end

private

  def defaults
    {
      document_type: "manual",
      change_note: "New section added.",
    }
  end
end
