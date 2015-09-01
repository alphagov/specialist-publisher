require "multi_json"

class PublishingApiFinderLoader
  def initialize(folder)
    @folder = folder
  end

  def finders
    matching_finder_filenames.map do |filename|
      metadata_file = File.join(folder, "metadata", filename)
      schema_file = File.join(folder, "schemas", filename)

      {
        metadata: MultiJson.load(File.read(metadata_file)),
        schema: MultiJson.load(File.read(schema_file)),
        timestamp: File.mtime(metadata_file)
      }
    end
  end

  def schema_files_missing_metadata
    schema_files.reject { |filename| metadata_files.include?(filename) }
  end

  def metadata_files_missing_schema
    metadata_files.reject { |filename| schema_files.include?(filename) }
  end

private
  attr_reader :folder

  def matching_finder_filenames
    metadata_files.select { |filename| schema_files.include?(filename) }
  end

  def metadata_files
    @matadata_files ||= Dir.glob(File.join(folder, "metadata/*.json")).map do|file|
      File.basename(file)
    end
  end

  def schema_files
    @schema_files ||= Dir.glob(File.join(folder, "schemas/*.json")).map do|file|
      File.basename(file)
    end
  end
end
