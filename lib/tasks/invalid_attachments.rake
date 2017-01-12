desc "Find documents with invalid attachments"
task invalid_attachments: :environment do
  documents = Services.publishing_api.get_content_items(
    document_type: "cma_case",
    per_page: 999999,
  )["results"]

  documents.each do |document|
    doc_body = document["details"]["body"][0]["content"]
    content_id = document["content_id"]
    attachments = document["details"]["attachments"]

    my_document = Document.new(document)
    my_document.body = doc_body
    my_document.content_id = content_id

    if !attachments.nil?
      attachment_collection = []
      attachments.each do |attachment|
        attachment_collection << Attachment.new(attachment)
      end
      my_document.attachments = AttachmentCollection.new(attachment_collection)
    end

    report = AttachmentReporter.report(my_document)

    unmatched = report.fetch(:unmatched_snippets)

    unmatched.uniq.each do |filename|
      filename = CGI::escapeHTML(filename)
      puts "#{my_document.content_id} contains an attachment that can't be found: '#{filename}'"
    end
  end
end
