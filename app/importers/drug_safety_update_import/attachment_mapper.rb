require "validators/attachment_snippet_in_body_validator"
require "document_import/attachment_helpers"

module DrugSafetyUpdateImport
  class AttachmentMapper
    include ::DocumentImport::AttachmentHelpers

    def initialize(import_mapper, repo, base_path = ".")
      @import_mapper = import_mapper
      @repo = repo
      @base_path = base_path
    end

    def call(data)
      document = import_mapper.call(data)

      if document.valid?
        data["_assets"].each do |asset_data|
          attach_asset(document, asset_data, data)
        end

        repo.store(document)
      end

      document
    end

  private
    attr_reader :import_mapper, :repo, :base_path

    def attach_asset(document, asset_data, data)
      attachment = add_attachment(
        document,
        attachable_file_attributes(base_path, asset_data),
      )

      replace_link_with_snippet(document, asset_data, attachment)
    end

    def imported_document(data)
      AttachmentSnippetInBodyValidator.new(
        import_mapper.call(data)
      )
    end

    def add_attachment(document, asset_data)
      document.add_attachment(asset_data)
    end

    def replace_link_with_snippet(document, asset, attachment)
      search = "[ASSET_TAG](#ASSET#{asset.fetch("assetid")})"
      replace_in_body(document, search, attachment.snippet)
    end
  end
end
