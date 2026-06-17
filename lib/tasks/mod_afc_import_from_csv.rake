desc "Import armed forces covenant businesses from a CSV file and save them"

task :mod_afc_import_from_csv, %i[csv_file_path dry_run] => :environment do |_, args|
  csv_file_path = args[:csv_file_path]
  dry_run = args[:dry_run]&.to_s&.downcase == "true"
  schema = FinderSchema.load_from_schema("armed_forces_covenant_businesses")

  imported_count = 0
  invalid_rows = []
  documents_to_import = []
  errors_on_save = 0

  CSV.foreach(csv_file_path, headers: true).with_index(2) do |row, line_number|
    business_name = row["Account Name"]
    date_value = row["Date AFC Signed"].present? ? Date.parse(row["Date AFC Signed"]).strftime("%Y-%m-%d") : nil
    region_value = get_facet_value_from_schema_based_on_label(schema, "armed_forces_covenant_business_region", row["Account Region"])
    company_size_value = get_facet_value_from_schema_based_on_label(schema, "armed_forces_covenant_business_company_size", row["Company Size"])
    industry_value = get_facet_value_from_schema_based_on_label(schema, "armed_forces_covenant_business_industry", row["Industry"])
    ownership_value = get_facet_value_from_schema_based_on_label(schema, "armed_forces_covenant_business_ownership", row["Ownership"])
    pledge_value = get_pledge_values(schema, row)
    summary = generate_summary
    body = generate_body(business_name, row)

    required_fields = {
      "title" => business_name,
      "summary" => summary,
      "body" => body,
      "armed_forces_covenant_business_region" => region_value,
      "armed_forces_covenant_business_company_size" => company_size_value,
      "armed_forces_covenant_business_industry" => industry_value,
      "armed_forces_covenant_business_ownership" => ownership_value,
      "armed_forces_covenant_business_date_signed" => date_value,
    }

    if required_fields.values.any?(&:blank?)
      invalid_rows << {
        line: line_number,
        missing_fields: required_fields.select { |_, v| v.blank? }.keys,
        title: business_name,
      }
    else
      required_fields.merge!({ "armed_forces_covenant_business_pledged" => pledge_value }) if pledge_value.any?
      documents_to_import << { row: row, attributes: required_fields }
    end
  end

  if invalid_rows.any? && !dry_run
    raise StandardError, "CSV import failed: #{invalid_rows.count} row(s) have missing required fields."
  end

  documents_to_import.reverse.each do |document_data|
    afc_business = ArmedForcesCovenantBusiness.new(**document_data[:attributes].deep_symbolize_keys)

    if dry_run
      afc_business.valid?
    else
      afc_business.save
    end

    if afc_business.errors.blank?
      puts "Saved document: '#{afc_business.title}'"
      imported_count += 1
    else
      puts "Error when saving document: '#{afc_business.title}'"
      errors_on_save += 1
    end
  end

  report_mod_import_result(imported_count, invalid_rows, errors_on_save, dry_run)
end

def get_facet_value_from_schema_based_on_label(schema, facet_key, label)
  item = schema.allowed_values_for(facet_key)
                     .to_h { |val| [val.fetch("label"), val.fetch("value")] }
                     .find { |l, _v| l == label }
  item ? item[1] : nil
end

def get_pledge_values(schema, row)
  pledged_values = []

  schema.allowed_values_for("armed_forces_covenant_business_pledged")
    .to_h { |val| [val.fetch("label"), val.fetch("value")] }
    .each do |pledge_label, pledge_value|
    pledged_values << pledge_value if row[pledge_label] == "Pledged" || (pledge_label == "Bespoke Pledges" && row[pledge_label].present?)
  end

  pledged_values
end

def get_pledge_labels(row)
  pledge_labels = []

  FinderSchema
    .load_from_schema("armed_forces_covenant_businesses")
    .allowed_values_for("armed_forces_covenant_business_pledged")
    .to_h { |val| [val.fetch("label"), val.fetch("value")] }
    .each_key do |pledge_label|
    pledge_labels << pledge_label if row[pledge_label] == "Pledged"
  end

  pledge_labels
end

def report_mod_import_result(imported_count, skipped_rows, errors_on_save, dry_run)
  puts "\n----------------------REPORT----------------------\n\n"
  dry_run_prefix = dry_run ? "[DRY RUN] " : ""
  puts "#{dry_run_prefix}Imported: #{imported_count} document(s)"
  puts "Errors on save: #{errors_on_save} document(s)"
  puts "Skipped: #{skipped_rows.count} row(s)"

  if skipped_rows.any?
    puts "\nSkipped row details:"
    skipped_rows.each do |row|
      puts "- Line #{row[:line]}: Missing #{row[:missing_fields].join(', ')} (Title: #{row[:title] || 'N/A'})"
    end
  end
end

def generate_summary
  "We, the undersigned, commit to honour the Armed Forces Covenant and support the Armed Forces Community. We recognise the value Serving Personnel, both Regular and Reservists, Veterans and military families contribute to our business and our country."
end

def generate_body(business_name, row)
  pledge_list = get_pledge_labels(row).reject { |l| l == "Bespoke Pledges" }.map { |label| "- #{label}" }.join("\n")
  optional_bespoke_pledge = row["Bespoke Pledges"].present? ? "\nWe also pledge the following:\n\n#{row['Bespoke Pledges']}" : ""

  <<~GOVSPEAK
    ## The Armed Forces Covenant

    > An enduring covenant between the people of the United Kingdom, Her Majesty's Government and all those who serve or have served in the Armed Forces of the Crown and their families

    The first duty of Government is the defence of the realm. Our Armed Forces fulfil that responsibility on behalf of the Government, sacrificing some civilian freedoms, facing danger and, sometimes, suffering serious injury or death as a result of their duty. Families also play a vital role in supporting the operational effectiveness of our Armed Forces. In return, the whole nation has a moral obligation to the members of the Naval Service, the Army and the Royal Air Force, together with their families. They deserve our respect and support, and fair treatment.

    Those who serve in the Armed Forces, whether Regular or Reserve, those who have served in the past, and their families, should face no disadvantage compared to other citizens in the provision of public and commercial services. Special consideration is appropriate in some cases, especially for those who have given most such as the injured and the bereaved.

    This obligation involves the whole of society: it includes voluntary and charitable bodies, private organisations, and the actions of individuals in supporting the Armed Forces. Recognising those who have performed military duty unites the country and demonstrates the value of their contribution. This has no greater expression than in upholding this Covenant.

    ### Section 1: Principles of the Armed Forces Corporate Covenant

    1.1 We #{business_name} will endeavour in our business dealings to uphold the key principles of the Armed Forces Covenant, which are:

    - no member of the Armed Forces Community should face disadvantage in the provision of public and commercial services compared to any other citizen;
    - and in some circumstances that special treatment may be appropriate especially for the injured or bereaved.

    ### Section 2: Demonstrating our commitment

    2.1 #{business_name} recognises the value serving personnel, reservists, veterans and military families bring to our business. We will seek to uphold the principles of the Armed Forces Covenant, by pledging to the following:

    #{pledge_list}
    #{optional_bespoke_pledge}

    2.2 We will publicise these commitments through our literature and/or on our website, setting out how we will seek to honour them and inviting feedback from the Service community and our customers on how we are doing.
  GOVSPEAK
end
