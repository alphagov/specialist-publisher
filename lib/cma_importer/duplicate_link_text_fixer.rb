module CMAImporter
  class DuplicateLinkTextFixer
    def self.dedupe(edition)
      deduped_body = edition.attachments.reduce(edition.body) do |body, attachment|
        title = Regexp.quote(attachment.title)
        filename = Regexp.quote(attachment.filename)
        body.gsub(/#{title} (\[InlineAttachment:#{filename}\])/, '\1')
      end

      edition.update_attribute(:body, deduped_body)
    end
  end
end
