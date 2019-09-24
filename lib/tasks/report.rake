namespace :report do
  desc "validate inline attachments snippets for all documents of a class"
  task :attachments, [:class_name] => :environment do |_, args| # rubocop:disable Metrics/BlockLength - it could be extracted into a PORO
    if args.class_name.blank? || args.class_name == "all"
      Rails.application.eager_load!
      classes = Document.subclasses
    else
      classes = [args.class_name.constantize]
    end

    classes.each do |klass| # rubocop:disable Metrics/BlockLength
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
        rescue StandardError => e
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

  desc "generate a report of counts of published PDF documents per organisation to help the Content Operating Model team"
  task pdf_content_operating_model: :environment do # rubocop:disable Metrics/BlockLength - it could be extracted into a PORO
    def unique_owning_organisation_ids
      @unique_owning_organisation_ids ||= all_document_classes.map { |document| document.organisations.first }.uniq
    end

    def all_document_classes
      @all_document_classes ||= FinderSchema.schema_names.map do |schema_name|
        schema_name.singularize.camelize.constantize
      end
    end

    def organisation_name_from_id(org_id)
      Services.publishing_api.get_content(org_id)["title"]
    end

    def each_document_content_id_and_state_history(document_class, &block)
      ReportDocumentPaginator.new(document_class, %i[content_id state_history]).each(&block)
    end

    def document_published_prior_to_date?(document, date)
      document.public_updated_at && document.public_updated_at.to_date >= date
    end

    first_period_start_date = ENV.fetch("FIRST_PERIOD_START_DATE", Date.parse("2016-01-01"))
    last_time_period_days = ENV.fetch("LAST_TIME_PERIOD_DAYS", 30)
    last_time_period_start_date = last_time_period_days.days.ago

    organisation_published_pdfs_total_counts_hash = Hash[unique_owning_organisation_ids.map { |o| [o, 0] }]
    organisation_published_pdfs_since_first_period_counts_hash = Hash[unique_owning_organisation_ids.map { |o| [o, 0] }]
    organisation_published_pdfs_since_second_period_counts_hash = Hash[unique_owning_organisation_ids.map { |o| [o, 0] }]

    all_document_classes.each do |document_class|
      each_document_content_id_and_state_history(document_class) do |document_id_and_state_hash|
        state_history = document_id_and_state_hash["state_history"]

        # Ignore docs that have never been published
        next if state_history.count == 1 && state_history["1"] == "draft"

        content_id = document_id_and_state_hash["content_id"]

        unique_pdf_attachment_urls_for_document = []

        # Walk through the history of document versions looking for published PDF attachments
        state_history.each_pair do |version_number, version_state|
          next if version_state == "draft"

          response = Services.publishing_api.get_content(content_id, "version" => version_number)

          current_document_version = Document.from_publishing_api(response.parsed_content)

          current_document_version.attachments.each do |attachment|
            next if attachment.content_type != "application/pdf"

            # Uses the URL of the attachment as a way to detect if the current attachment is unique
            # in the version history and only count it if so.
            next if unique_pdf_attachment_urls_for_document.include? attachment.url

            owning_organisation_id = document_class.organisations.first

            organisation_published_pdfs_total_counts_hash[owning_organisation_id] += 1

            if document_published_prior_to_date?(current_document_version, first_period_start_date)
              organisation_published_pdfs_since_first_period_counts_hash[owning_organisation_id] += 1
            end

            if document_published_prior_to_date?(current_document_version, last_time_period_start_date)
              organisation_published_pdfs_since_second_period_counts_hash[owning_organisation_id] += 1
            end

            unique_pdf_attachment_urls_for_document << attachment.url
          end
        end
      end
    end

    document_report_filename = Rails.root.join("content-operating-report-for-pdf-documents-#{Time.zone.today.strftime('%Y-%m-%d')}.csv")

    require "csv"

    CSV.open(document_report_filename, "w") do |document_csv|
      document_csv << [
        "Organisation",
        "Total published PDF attachments",
        "#{first_period_start_date} - present PDF attachments",
        "Last #{last_time_period_days} days PDF attachments",
      ]

      unique_owning_organisation_ids.each do |org_id|
        document_csv << [
          organisation_name_from_id(org_id),
          organisation_published_pdfs_total_counts_hash[org_id],
          organisation_published_pdfs_since_first_period_counts_hash[org_id],
          organisation_published_pdfs_since_second_period_counts_hash[org_id],
        ]
      end
    end
  end

  desc "generate a report on all documents to help the Content Operating Model team"
  task content_operating_model: :environment do # rubocop:disable Metrics/BlockLength - it could be extracted into a PORO
    def all_document_classes
      @all_document_classes ||= FinderSchema.schema_names.map do |schema_name|
        schema_name.singularize.camelize.constantize
      end
    end

    def public_url_for(document)
      URI.join(Plek.new.website_root, document["base_path"]).to_s
    end

    def each_document(document_class, &block)
      document_field_params = %i[base_path content_id publication_state first_published_at]
      ReportDocumentPaginator.new(document_class, document_field_params).each(&block)
    end

    def organisations_for_document_class(document_class)
      org_ids = document_class.finder_schema.organisations
      org_ids.map do |org_id|
        Services.publishing_api.get_content(org_id)["title"]
      end
    end

    def get_finder_document_hash(finder_schema)
      begin
        finder_document = Services.publishing_api.get_content(finder_schema.content_id).to_hash
      rescue GdsApi::HTTPErrorResponse
        finder_document = {}
      end
      {
        "base_path" => finder_schema.base_path,
        "first_published_at" => finder_document["first_published_at"] || "Never published to GOV.UK",
        "publication_state" => finder_document["publication_state"] || "not-published",
      }
    end

    require "csv"

    document_report_filename = Rails.root.join("content-operating-report-for-documents-#{Time.zone.today.strftime('%Y-%m-%d')}.csv")
    finder_report_filename = Rails.root.join("content-operating-report-for-finders-#{Time.zone.today.strftime('%Y-%m-%d')}.csv")

    CSV.open(document_report_filename, "w") do |document_csv|
      CSV.open(finder_report_filename, "w") do |finder_csv|
        document_csv << ["URL", "Organisation(s)", "Finder", "Status", "First published at"]
        finder_csv << ["URL", "Organisation(s)", "Status", "How many documents", "First published at"]
        all_document_classes.each do |document_class|
          document_count = 0
          organisations_for_csv = organisations_for_document_class(document_class).join(", ")
          each_document(document_class) do |document_hash|
            document_count += 1
            document_csv << [public_url_for(document_hash),
                             organisations_for_csv,
                             document_class.title,
                             document_hash["publication_state"],
                             document_hash["first_published_at"] || "Never published to GOV.UK"]
          end
          finder_document_hash = get_finder_document_hash(document_class.finder_schema)
          finder_csv << [public_url_for(finder_document_hash),
                         organisations_for_csv,
                         finder_document_hash["publication_state"],
                         document_count,
                         finder_document_hash["first_published_at"]]
        end
      end
    end
  end
end
