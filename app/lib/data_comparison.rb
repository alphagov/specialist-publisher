require "hashdiff"

module DataComparison
module_function

  def compare(content_id)
    Services.publishing_api.client.options[:timeout] = 30

    puts "<<<<<"
    puts "Comparing #{content_id}"

    before = nil

    begin
      before = Services.publishing_api.get_content(content_id).to_hash
    rescue GdsApi::HTTPServerError
      puts "ERROR: Could not find content_id '#{content_id}'"
      return
    end

    document = Document.find(content_id)

    unless document.update_type
      document.update_type = "major"
      document.change_note = "some change note"
    end

    if document.save
      puts "Saving document"
    else
      puts "ERROR: Failed to save document"
      puts document.errors.messages.inspect
      return
    end

    if document.published?
      puts "Publishing document"
      document.publish
    elsif document.unpublished?
      puts "Publishing document"
      document.publish
      puts "Unpublishing document"
      document.unpublish
    end

    after = Services.publishing_api.get_content(content_id).to_hash

    diff = Hashdiff.diff(before, after)
    puts "Differences:"
    puts diff

    puts "<<<<<"
  end
end
