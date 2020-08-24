require "hashdiff"
require "services"

module DataComparison
module_function

  def compare(content_id)
    Services.publishing_api.client.options[:timeout] = 30

    debug "<<<<<"
    debug "Comparing #{content_id}"

    before = nil

    begin
      before = Services.publishing_api.get_content(content_id).to_hash
    rescue GdsApi::HTTPServerError
      debug "ERROR: Could not find content_id '#{content_id}'"
      return
    end

    document = Document.find(content_id)

    unless document.update_type
      document.update_type = "major"
      document.change_note = "some change note"
    end

    if document.save
      debug "Saving document"
    else
      debug "ERROR: Failed to save document"
      debug document.errors.messages.inspect
      return
    end

    if document.published?
      debug "Publishing document"
      document.publish
    elsif document.unpublished?
      debug "Publishing document"
      document.publish
      debug "Unpublishing document"
      document.unpublish
    end

    after = Services.publishing_api.get_content(content_id).to_hash

    diff = Hashdiff.diff(before, after)
    debug "Differences:"
    debug diff

    debug "<<<<<"
  end

  def debug(message)
    Rails.logger.debug(message)
  end
end
