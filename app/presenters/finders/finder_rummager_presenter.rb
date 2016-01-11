FinderRummagerPresenter = Struct.new(:file, :timestamp) do
  def type
    "edition"
  end

  def id
    file.fetch("base_path")
  end

  def to_json
    {
      title: file.fetch("name"),
      description: file.fetch("description", ""),
      link: file.fetch("base_path"),
      format: "finder",
      public_timestamp: timestamp,
      specialist_sectors: file.fetch("topics", []),
    }
  end
end
