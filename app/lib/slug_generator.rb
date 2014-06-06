class SlugGenerator
  def initialize(dependencies)
    @prefix = dependencies.fetch(:prefix)
  end

  def call(title)
    [
      @prefix,
      slugify_title(title)
    ].join("/")
  end

  private

  def slugify_title(title)
    title
      .downcase
      .gsub(/[^a-zA-Z0-9]+/, "-")
      .gsub(/-+$/, "")
  end
end
