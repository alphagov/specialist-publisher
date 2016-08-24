desc "validate inline attachments snippets for all documents of a class"
namespace :report do
  task :attachments, [:class_name] => :environment do |_, args|
    if args.class_name.blank? || args.class_name == "all"
      Rails.application.eager_load!
      classes = Document.subclasses
    else
      classes = [args.class_name.constantize]
    end

    classes.each do |klass|
      puts "Validating inline attachment snippets for #{klass}"

      page_size = 10

      response = klass.all(1, page_size)
      pages = response.to_hash.fetch("pages")

      content_ids = Enumerator.new do |y|
        1.upto(pages) do |page|
          response = klass.all(page, page_size)
          results = response.to_hash.fetch("results")
          results.each { |r| y.yield r.fetch("content_id") }
        end
      end

      content_ids.each do |content_id|
        document = Document.find(content_id)

        begin
          report = AttachmentReporter.report(document)
        rescue => e
          puts "\nfailed to generate report for #{klass} #{content_id}:"
          puts "  #{e.class}: #{e.message}\n"
          next
        end

        unmatched = report.fetch(:unmatched_snippets)
        unused = report.fetch(:unused_attachments)

        if unmatched.any?
          puts "\n#{klass} #{content_id} has invalid inline attachments:"

          unmatched.group_by { |u| u }.each do |u, array|
            puts "  #{array.count}: '#{u}'"
          end

          if unused.any?
            puts "Maybe they're supposed to be one of these unused attachments:"
            unused.each { |u| puts "  '#{u}'" }
          end

          puts
        else
          print "."
        end
      end
    end

    puts
  end
end
