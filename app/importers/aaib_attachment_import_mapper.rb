require "validators/attachment_snippet_in_body_validator"

class AaibAttachmentImportMapper
  def initialize(import_mapper, repository, base_path = ".")
    @import_mapper = import_mapper
    @repository = repository
    @base_path = base_path
  end

  def call(data)
    imported_document(data).tap do |document|
      data["assets"].each do |asset|
        attach_asset(document, asset)
      end
      repository.store(document)
    end
  end

private
  attr_reader :import_mapper, :repository, :base_path

  def imported_document(data)
    AttachmentSnippetInBodyValidator.new(
      import_mapper.call(data)
    )
  end

  def attach_asset(document, asset)
    attachment_data = {
      title: asset["title"],
      filename: asset["original_filename"],
      file: File.open(File.join(base_path, "import", asset["filename"])),
    }

    attachment = document.add_basic_attachment(attachment_data)
    replace_link_with_snippet(document, asset, attachment)
  end

  def replace_link_with_snippet(document, asset, attachment)
    search = "[ASSET_TAG](#ASSET#{asset["assetid"]})"
    if document.body.include?(search)
      new_body = document.body.gsub(search, attachment.snippet)
      document.update(document.attributes.merge({body: new_body}))
    end
  end
end
