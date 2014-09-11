class ManualBuilder
  def initialize(dependencies)
    @slug_generator = dependencies.fetch(:slug_generator)
    @id_generator = dependencies.fetch(:id_generator)
    @factory = dependencies.fetch(:factory)
  end

  def call(attrs)
    @attrs = attrs

    factory.call(defaults.merge(attrs))
  end

  private

  attr_reader :slug_generator, :id_generator, :factory, :attrs

  def defaults
    {
      id: id,
      slug: slug,
      summary: "",
      body: "",
      state: "draft",
      organisation_slug: "",
      updated_at: "",
    }
  end

  def id
    id_generator.call
  end

  def slug
    slug_generator.call(attrs.fetch(:title))
  end
end
