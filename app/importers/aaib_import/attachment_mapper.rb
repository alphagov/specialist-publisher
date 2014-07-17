require "validators/attachment_snippet_in_body_validator"

module AaibImport
  class AttachmentMapper
    def initialize(import_mapper, repo, base_path = ".")
      @import_mapper = import_mapper
      @repo = repo
      @base_path = base_path
    end

    def call(data)
      document = import_mapper.call(data)

      if document.valid?
        data["assets"]
          .each do |asset_data|
            attachment = add_attachment(
              document,
              attachable_file_attributes(asset_data),
            )

            replace_link_with_snippet(document, asset_data, attachment)
          end

        repo.store(document)
      end

      document
    end

  private
    attr_reader :import_mapper, :repo, :base_path

    def imported_document(data)
      AttachmentSnippetInBodyValidator.new(
        import_mapper.call(data)
      )
    end

    def add_attachment(document, asset_data)
      document.add_attachment(asset_data)
    end

    def attachable_file_attributes(asset)
      file = File.open(File.join(base_path, asset["filename"]))
      file.define_singleton_method(:original_filename) {
        asset.fetch("original_filename")
      }

      {
        title: asset.fetch("title"),
        filename: asset.fetch("original_filename"),
        file: file,
      }
    end

    def replace_link_with_snippet(document, asset, attachment)
      search = "[ASSET_TAG](#ASSET#{asset.fetch("assetid")})"
      if document.body.include?(search)
        new_body = document.body.gsub(search, attachment.snippet)
        document.update(body: new_body)
      end
    end
  end
end
