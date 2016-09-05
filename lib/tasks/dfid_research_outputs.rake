namespace :dfid_research_outputs do
  desc "Clean up invalid country codes"
  task cleanup_country_codes: :environment do
    filepath = ENV["INVALID_COUNTRY_CODES_FILEPATH"]
    no_file_message = <<-ERR.strip_heredoc
    Please specify a file containing invalid country codes in the format:

    content_id, invalid_country_codes
    cdfded1b-73ec-46d1-95a5-eb97856503fd, BR TH PE BD TZ NA JP ET RS WS CS
    ERR

    raise no_file_message unless filepath
    invalid_country_code_data = File.readlines(filepath)

    valid_country_codes = FinderSchema.new("dfid_research_outputs").options_for("country").map(&:last)

    invalid_country_code_data.each do |line|
      content_id, country_codes = line.split(",")
      country_codes = country_codes.split(" ").compact
      invalid_country_codes = (country_codes - valid_country_codes)

      doc = Document.find(content_id)
      published = doc.published?

      if doc
        if doc.country && invalid_country_codes.any?
          doc.country = (doc.country - invalid_country_codes)
          doc.update_type = "minor"
          payload = DocumentPresenter.new(doc).to_json
          puts "ContentItem '#{content_id}' updated with countries: #{doc.country}"
          Services.publishing_api.put_content(doc.content_id, payload)

          if published
            Services.publishing_api.publish(doc.content_id, "minor")
            puts "published"
          end
        end
      else
        puts "No document found for #{content_id}"
      end
    end
  end
end
