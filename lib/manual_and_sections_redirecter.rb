class ManualAndSectionsRedirecter
  def initialize(args)
    @publishing_api = SpecialistPublisher.services(:publishing_api)
    @logger = args[:logger] || STDOUT
    @base_path = args[:base_path]
    @destination = args[:destination]
  end

  def redirect
    run
  end

private

  attr_reader :base_path, :destination, :logger, :publishing_api

  def run
    begin
      manuals_response = publishing_api.get_content_items(publishing_app: "specialist-publisher", document_type: "manual", fields: %w(base_path content_id))
    rescue GdsApi::HTTPErrorResponse => e
      raise "Could not retrieve specialist-publisher manuals from publishing api -> #{e}"
    end

    manual = manuals_response.to_hash["results"].find { |item| item["base_path"] == base_path }

    raise "Could not find manual with base_path: #{base_path}" unless manual

    manual_content_id = manual["content_id"]

    redirect_item(manual_content_id, redirect_payload(base_path))
    redirect_item(manual_content_id, redirect_payload("#{base_path}/updates"))

    logger.puts "Redirecting #{manual['base_path']} to #{destination}"

    begin
      sections_response = publishing_api.get_linked_items(manual_content_id, link_type: "manual", fields: %w(base_path content_id))
    rescue GdsApi::HTTPErrorResponse => e
      raise "Could not retrieve specialist-publisher sections -> #{e}"
    end

    manual_sections = sections_response.to_hash

    manual_sections.each do |section|
      redirect_item(section["content_id"], redirect_payload(section["base_path"]))
      logger.puts "Redirecting #{section['base_path']} to #{destination}"
    end
  end

  def redirect_item(content_id, payload)
    publishing_api.put_content(content_id, payload)
    publishing_api.publish(content_id, "major")
  end

  def redirect_payload(from_path)
    {
      format: "redirect",
      publishing_app: "specialist-publisher",
      update_type: "major",
      base_path: from_path,
      redirects: [
        {
          path: from_path,
          type: "exact",
          destination: destination
        }
      ]
    }
  end
end
