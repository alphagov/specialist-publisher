def pre_production
  pre_production_formats = []
  Dir["lib/documents/schemas/*.yml"].each do |file|
    parsed_file = YAML.load_file(file)
    if parsed_file["pre_production"] && parsed_file["base_path"] != "/dfid-research-outputs"
      pre_production_formats << parsed_file["filter"]["document_type"]
    end
  end
  pre_production_formats
end

PRE_PRODUCTION = pre_production
