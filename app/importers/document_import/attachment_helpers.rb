module DocumentImport
  module AttachmentHelpers
  private
    def replace_in_body(document, search, replacement)
      if document.body.include?(search)
        new_body = document.body.gsub(search, replacement)
        document.update(body: new_body)
      end
    end

    def attachable_file_attributes(base_path, asset_data)
      original_filename = asset_data.fetch("original_filename", asset_data["filename"])

      file = File.open(File.join(base_path, asset_data["filename"]))
      file.define_singleton_method(:original_filename) { original_filename }

      {
        title: clean_title(asset_data.fetch("title")),
        filename: original_filename,
        file: file,
      }
    end

    def clean_title(string)
      string.gsub("_", "-")
    end
  end
end
