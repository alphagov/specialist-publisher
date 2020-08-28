namespace :dfid do
  desc "Migrate research outputs"
  task migrate_research_outputs: :environment do
    content_ids = Republisher.content_ids_for_document_type("dfid_research_output")
    content_ids.each do |content_id|
      RepublishService.new.call(content_id) do |payload|
        puts "#{payload[:base_path]} - #{payload[:title]}"

        payload[:document_type] = "research_for_development_output"

        base_path = payload[:base_path].gsub("dfid-research-outputs", "research-for-development-outputs")
        payload[:base_path] = base_path
        payload[:routes][0][:path] = base_path

        payload[:details][:metadata] = payload[:details][:metadata].tap do |metadata|
          metadata[:research_document_type] = metadata.delete(:dfid_document_type) || []
          metadata[:authors] = metadata.delete(:dfid_authors) || []
          metadata[:theme] = metadata.delete(:dfid_theme) || []
          if (review_status = metadata.delete(:dfid_review_status))
            metadata[:review_status] = review_status
          end
        end
      end
    end
  end
end
