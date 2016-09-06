class InlineAttachmentsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    report = AttachmentReporter.report(record)
    unmatched = report.fetch(:unmatched_snippets)

    unmatched.uniq.each do |filename|
      filename = CGI::escapeHTML(filename)
      message = "contains an attachment that can't be found: '#{filename}'"

      record.errors.add(attribute, message)
    end
  end
end
