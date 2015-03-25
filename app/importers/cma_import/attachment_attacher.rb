class CmaImportAttachmentAttacher
  include ::DocumentImport::AttachmentHelpers

  def initialize(create_document_service:, document_repository:, assets_directory:)
    @create_document_service = create_document_service
    @document_repository = document_repository
    @assets_directory = assets_directory
  end

  def call(data)
    document = create_document_service.call(data)

    assets = data.fetch("assets", []).map { |asset_data|
      attach_asset_to_document(asset_data, document)
    }

    document_repository.store(document)

    Presenter.new(
      document,
      assets,
    )
  end

private
  attr_reader :create_document_service, :document_repository, :assets_directory

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

      valid_asset
    else
      unlinked_asset(filename)
    end
  rescue DocumentImport::FileNotFound => e
    missing_asset(e)
  end

  def find_link_in_document(asset_data, document)
    url = asset_data.fetch("original_url")

    match = document.body.match(
      %r!
        # markdown link
        \[([^\]]+)\] # link text
        \(#{url}\)

        |

        # html link
        <a\s+href="#{url}">
          ([^<]+) # link text
        </a>
      !x
    )

    if match
      OpenStruct.new(
        match: match.to_s,
        title: match.captures.compact.first,
      )
    end
  end

  def valid_asset
    OpenStruct.new(
      valid?: true,
    )
  end

  def unlinked_asset(filename)
    OpenStruct.new(
      valid?: false,
      error: "#{filename} not linked from body",
    )
  end

  def missing_asset(error)
    OpenStruct.new(
      valid?: false,
      error: error.message,
    )
  end

  class Presenter < SimpleDelegator
    def initialize(document, assets)
      @assets = assets

      super(document)
    end

    def import_notes
      super.concat(messages)
    end

  private
    attr_reader :assets

    def messages
      [
        attachment_count_message,
        invalid_attachments_message,
      ].compact
    end

    def attachment_count_message
      "number of attachments: #{assets.count}"
    end

    def invalid_attachments_message
      errors = assets.reject(&:valid?).map(&:error).join(", ")

      if errors.present?
        "attachments with problems: #{errors}"
      end
    end
  end
end
