require "document_import/attachment_helpers"

module DfidImport
  class AttachmentMapper
    include ::DocumentImport::AttachmentHelpers

    def initialize(import_mapper, repo, logger, base_path = ".")
      @import_mapper = import_mapper
      @repo = repo
      @logger = logger
      @base_path = base_path
    end

    def call(data)
      document = import_mapper.call(data)
      return document if data["attachments"].size < 1

      if document.valid?
        data["attachments"].each do |asset|
          attach_asset(document, asset, data)
        end

        repo.store(document)
      end

      document
    end

  private
    attr_accessor :import_mapper, :repo, :logger, :base_path

    def attach_asset(document, asset_data, data)
      begin
        asset_path = File.join(base_path, data.fetch("import_source"))

        attachment = document.add_attachment(
          attachable_file_attributes(asset_path, asset_data)
        )

        replace_whitehall_snippet_with_snippet(document, attachment, asset_data)
      rescue Errno::ENOENT
        # Some files on whitehall aren't available bc they're stuck in
        # 'Virus scanning'.
        logger.warn("Couldn't attach document", {
          filename: asset_data.fetch("filename"),
          source: data.fetch("import_source"),
        })
      end
    end

    def replace_whitehall_snippet_with_snippet(document, attachment, asset)
      search = "[InlineAttachment:#{asset.fetch("identifier")}]"
      replace_in_body(document, search, attachment.snippet)
    end
  end
end
