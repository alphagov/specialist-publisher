require "multi_json"

class FinderLoader
  def finders(pre_production_only: false)
    data_objects = files.map do |json_schema|
      {
        file: MultiJson.load(File.read(json_schema)),
        timestamp: File.mtime(json_schema),
      }
    end
    pre_production_only ? data_objects.select { |obj| obj[:file]["pre_production"] == true } : data_objects
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

private

  def files
    @files ||= Dir.glob("lib/documents/schemas/*.json")
  end
end
