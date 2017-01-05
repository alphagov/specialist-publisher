namespace :report do
  desc "validate inline attachments snippets for all documents of a class"
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

  desc "generate a report on all documents to help the Content Operating Model team"
  task content_operating_model: :environment do
    def all_document_classes
      @_all_document_classes ||= FinderSchema.schema_names.map do |schema_name|
        schema_name.singularize.camelize.constantize
      end
    end

    def public_url_for(document)
      URI.join(Plek.new.website_root, document['base_path']).to_s
    end

    class Paginator
      def initialize(document_class)
        @document_class = document_class
      end

      def document_type
        @document_type ||= @document_class.document_type
      end

      def params(page)
        {
          publishing_app: "specialist-publisher",
          document_type: document_type,
          fields: [
            :base_path,
            :content_id,
            :publication_state,
            :first_published_at,
          ],
          page: page,
          per_page: 100,
          order: "-last_edited_at",
        }
      end

      def each(&block)
        page = 1
        loop do
          response = Services.publishing_api.get_content_items(params(page))
          break if response['results'].empty?
          response['results'].each(&block)
          break if response['current_page'] >= response['pages']
          page += 1
        end
      end
    end

    def each_document(document_class, &block)
      Paginator.new(document_class).each(&block)
    end

    def organisations_for_document_class(document_class)
      org_ids = document_class.finder_schema.organisations
      org_ids.map do |org_id|
        Services.publishing_api.get_content(org_id)['title']
      end
    end

    require 'csv'

    output_filename = Rails.root.join("content-operating-report-#{Time.zone.today.strftime('%Y-%m-%d')}.csv")

    CSV.open(output_filename, 'w') do |csv|
      csv << ["URL", "Organisation(s)", "Finder", "Status", "First published at"]
      all_document_classes.each do |document_class|
        organisations_for_csv = organisations_for_document_class(document_class).join(', ')
        each_document(document_class) do |document_hash|
          csv << [
            public_url_for(document_hash),
            organisations_for_csv,
            document_class.title,
            document_hash['publication_state'],
            document_hash['first_published_at'] || "Never published to GOV.UK",
          ]
        end
      end
    end
  end
end
