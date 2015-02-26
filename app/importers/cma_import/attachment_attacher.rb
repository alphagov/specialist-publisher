class CmaImportAttachmentAttacher
  include ::DocumentImport::AttachmentHelpers

  def initialize(create_document_service, assets_directory)
    @create_document_service = create_document_service
    @assets_directory = assets_directory
  end

  def call(data)
    document = create_document_service.call(data)

    assets = data.fetch("assets", []).map { |asset_data|
      attach_asset_to_document(asset_data, document)
    }

    AssetAttachmentValidator.new(
      document,
      assets,
    )
  end

private
  attr_reader :create_document_service, :assets_directory

  def attach_asset_to_document(asset_data, document)
    # Get the link markdown for this asset out of the document body
    original_link = find_link_in_document(asset_data, document)
    filename = File.basename(asset_data.fetch("filename"))

    asset_title = original_link ? original_link.title : filename

    # Turn the asset_data into attributes we can use to build an attachment
    file_attributes = attachable_file_attributes(
      assets_directory,
      asset_data.merge("title" => asset_title),
    )

    # Make the attachment
    attachment = document.add_attachment(file_attributes)

    # Update the link in the document body
    if original_link
      replace_in_body(
        document,
        original_link.match,
        attachment.snippet,
      )

      AssetAttachmentValidator.valid_asset
    else
      AssetAttachmentValidator.unlinked_asset(filename)
    end
  rescue DocumentImport::FileNotFound => e
    AssetAttachmentValidator.missing_asset(e)
  end

  def find_link_in_document(asset_data, document)
    match = document.body.match(
      %r|\[([^\]]+)\]\(#{asset_data.fetch("original_url")}\)|
    )

    if match
      OpenStruct.new(
        match: match.to_s,
        title: match.captures.first,
      )
    end
  end

  class AssetAttachmentValidator < SimpleDelegator
    def initialize(document, assets)
      @document = document
      @assets = assets

      super(document)
    end

    def valid?
      super && assets_valid?
    end

    def errors
      super.merge(
        assets: assets_errors,
      )
    end

    def self.valid_asset
      OpenStruct.new(
        valid?: true,
      )
    end

    def self.unlinked_asset(filename)
      OpenStruct.new(
        valid?: false,
        error: "#{filename} not linked from body",
      )
    end

    def self.missing_asset(error)
      OpenStruct.new(
        valid?: false,
        error: error.message,
      )
    end

  private
    attr_reader :document, :assets

    def assets_valid?
      assets.all?(&:valid?)
    end

    def assets_errors
      assets.reject(&:valid?).map(&:error)
    end
  end
end
