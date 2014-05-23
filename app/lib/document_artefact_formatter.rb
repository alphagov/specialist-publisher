class DocumentArtefactFormatter

  def initialize(document)
    @document = document
  end

  def resource_id
    document.id
  end

  def name
    document.title
  end

  def slug
    document.slug
  end

  def kind
    "specialist-document"
  end

  def rendering_app
    "specialist-frontend"
  end

  def paths
    ["/#{document.slug}"]
  end

  def state
    state_mapping.fetch(document.publication_state)
  end

  def attributes
    {
      name: name,
      slug: slug,
      kind: kind,
      rendering_app: rendering_app,
      paths: paths,
      state: state,
    }
  end

  private

  attr_reader :document

  def state_mapping
    {
      "published"   => "live",
      "draft"       => "draft",
      "withdrawn"   => "archived",
    }
  end
end
