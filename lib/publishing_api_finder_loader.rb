require "multi_json"

class PublishingApiFinderLoader
  def finders
    files.map do |file|
      {
        file: YAML.load_file(file),
        timestamp: File.mtime(file)
      }
    end
  end

private

  def files
    @files ||= Dir.glob("lib/documents/schemas/*.yml")
  end
end
