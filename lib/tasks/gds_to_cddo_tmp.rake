desc "Migrate Service Standard Reports from GDS to CDDO "
task gds_to_cddo_tmp: :environment do
  content_ids = Republisher.content_id_and_locale_pairs_for_document_type("service_standard_report")

  content_ids.each do |content_id, locale|
    RepublishService.new.call(content_id, locale) do |payload|
      gds_markdown = "From: | [Government Digital Service](https://www.gov.uk/government/organisations/government-digital-service)"
      cddo_markdown = "From: | [Central Digital and Data Office](https://www.gov.uk/government/organisations/central-digital-and-data-office)"

      payload[:details][:body].each do |data|
        if data[:content].present?
          data[:content] = data[:content].gsub(gds_markdown, cddo_markdown)
        end
      end

      payload
    end
  end
end
