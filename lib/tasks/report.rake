namespace :report do
  task attachments: :environment do
    page_size = 10

    response = CmaCase.all(1, page_size)
    pages = response.to_hash.fetch("pages")

    content_ids = Enumerator.new do |y|
      1.upto(pages) do |page|
        response = CmaCase.all(page, page_size)
        results = response.to_hash.fetch("results")
        results.each { |r| y.yield r.fetch("content_id") }
      end
    end

    content_ids.each do |content_id|
      document = Document.find(content_id)
      klass = document.class

      begin
        report = AttachmentReporter.report(document)
      rescue => e
        puts "failed to generate report for #{klass} #{content_id}:"
        puts "  #{e.class}: #{e.message}\n\n"
        next
      end

      unmatched = report.fetch(:unmatched_snippets)
      unused = report.fetch(:unused_attachments)

      if unmatched.any?
        puts "#{klass} #{content_id} has invalid inline attachments:"

        unmatched.group_by { |u| u }.each do |u, array|
          puts "  #{array.count}: '#{u}'"
        end

        if unused.any?
          puts "Maybe they're supposed to be one of these unused attachments:"
          unused.each { |u| puts "  '#{u}'" }
        end

        puts
      end
    end
  end
end
