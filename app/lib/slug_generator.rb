class SlugGenerator
  def self.generate_slug(document)
    document_slug = document.title
      .downcase
      .gsub(/[^a-zA-Z0-9]+/, '-')
      .gsub(/-+$/, '')

    "cma-cases/#{document_slug}"
  end
end
