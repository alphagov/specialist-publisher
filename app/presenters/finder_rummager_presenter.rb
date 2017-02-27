FinderRummagerPresenter = Struct.new(:file, :timestamp) do
  def type
    "edition"
  end

  def id
    file.fetch("base_path")
  end

  def to_json
    {
      content_store_document_type: publishing_api_payload.fetch(:document_type),
      description: file.fetch("description", ""),
      format: "finder",
      link: file.fetch("base_path"),
      public_timestamp: timestamp,
      publishing_app: publishing_api_payload.fetch(:publishing_app),
      rendering_app: publishing_api_payload.fetch(:rendering_app),
      specialist_sectors: file.fetch("topics", []),
      title: file.fetch("name"),
    }
  end

private

  def publishing_api_payload
    @publishing_api_payload ||= FinderContentItemPresenter.new(file, timestamp).to_json
  end
end
