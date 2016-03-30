require "multi_json"

class PublishingApiFinderLoader
  def finders
    files.map do |file|
      {
        file: MultiJson.load(File.read(file)),
        timestamp: File.mtime(file)
      }
    end
  end

private

  def files
    @files ||= Dir.glob("lib/documents/schemas/*.json")
  end
end
