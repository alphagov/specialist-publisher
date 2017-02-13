FinderRummagerPresenter = Struct.new(:file, :timestamp) do
  def type
    "edition"
  end

  def id
    file.fetch("base_path")
  end

  def to_json
    {
      description: file.fetch("description", ""),
      format: "finder",
      link: file.fetch("base_path"),
      public_timestamp: timestamp,
      specialist_sectors: file.fetch("topics", []),
      title: file.fetch("name"),
    }
  end
end
