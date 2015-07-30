FinderRummagerPresenter = Struct.new(:metadata, :timestamp) do
  def type
    "edition"
  end

  def id
    metadata.fetch("base_path")
  end

  def attributes
    {
      "title" => metadata.fetch("name"),
      "description" => metadata.fetch("description", ""),
      "link" => metadata.fetch("base_path"),
      "format" => "finder",
      "public_timestamp" => timestamp,
      "specialist_sectors" => metadata.fetch("topics", []),
    }
  end
end
