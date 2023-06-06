require "multi_json"

class FinderLoader
  def finders
    files.map do |json_schema|
      {
        file: MultiJson.load(File.read(json_schema)),
        timestamp: File.mtime(json_schema),
      }
    end
  end

  def finder(name)
    json_schema = "lib/documents/schemas/#{name}.json"

    if File.exist?(json_schema)
      [{
        file: MultiJson.load(File.read(json_schema)),
        timestamp: File.mtime(json_schema),
      }]
    else
      raise "Could not find file: #{json_schema}"
    end
  end

  def finder_by_slug(slug)
    schema_file = files.find do |file|
      File.foreach(file).grep(/"base_path": "\/#{slug}"/).any?
    end

    raise "Could not find any schema with slug: #{slug}" if schema_file.nil?

    {
      file: MultiJson.load(File.read(schema_file)),
      timestamp: File.mtime(schema_file),
    }
  end

private

  def files
    @files ||= Dir.glob("lib/documents/schemas/*.json")
  end
end
