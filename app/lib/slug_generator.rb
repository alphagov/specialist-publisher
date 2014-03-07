class SlugGenerator
  def self.call(title)
    slug = title
      .downcase
      .gsub(/[^a-zA-Z0-9]+/, '-')
      .gsub(/-+$/, '')

    "cma-cases/#{slug}"
  end
end
