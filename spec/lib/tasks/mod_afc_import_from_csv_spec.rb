require "rails_helper"

RSpec.describe "mod_afc_import_from_csv", type: :task do
  let!(:csv_path) { "dummy_path.csv" }
  let(:task) { Rake::Task["mod_afc_import_from_csv"] }
  let(:publishing_api) { double("publishing-api") }

  before(:each) do
    task.reenable
  end

  it "imports documents from a CSV file, and logs successful import" do
    csv_data = [
      {
        "Account Name" => "ABC Company",
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "Pledged",
        "UK Service Spouses And Partners" => "0",
        "Flexible Leave For Spouses" => "0",
        "UK Reservists" => "0",
        "UK Cadets" => "0",
        "Armed Forces Day" => "0",
        "Reserve Forces Day" => "0",
        "Discounts	Armed Forces Charities" => "0",
        "UK Wounded, Injured And Sick" => "0",
        "Bespoke Pledges" => "-Custom Pledge text",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    afc_business_double = instance_double(
      ArmedForcesCovenantBusiness,
      save: true,
      errors: [],
      title: csv_data.first["Account Name"],
    )

    generated_body = generate_body("ABC Company", csv_data.first)
    expect(generated_body).to include("- Custom Pledge text") # will drop any leading "-", when generating the list

    expect(ArmedForcesCovenantBusiness).to receive(:new).with(
      "title": "ABC Company",
      "summary": generate_summary,
      "body": generated_body,
      "armed_forces_covenant_business_pledged": %w[armed-forces-friendly uk-service-veterans-and-leavers bespoke-pledges],
      "armed_forces_covenant_business_region": "wessex",
      "armed_forces_covenant_business_company_size": "large",
      "armed_forces_covenant_business_industry": "healthcare",
      "armed_forces_covenant_business_ownership": "private",
      "armed_forces_covenant_business_date_signed": "2025-06-01",
    ).and_return(afc_business_double)

    expect { task.execute(csv_file_path: csv_path) }.to output(/.*Saved document: 'ABC Company'.*REPORT.*Imported: 1 document\(s\).*Errors on save: 0 document\(s\).*Skipped: 0 row\(s\)/m).to_stdout
  end

  it "imports documents in reverse order, and logs successful imports" do
    csv_data = [
      {
        "Account Name" => "ABC Company",
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "Pledged",
        "UK Service Spouses And Partners" => "0",
        "Flexible Leave For Spouses" => "0",
        "UK Reservists" => "0",
        "UK Cadets" => "0",
        "Armed Forces Day" => "0",
        "Reserve Forces Day" => "0",
        "Discounts	Armed Forces Charities" => "0",
        "UK Wounded, Injured And Sick" => "0",
        "Bespoke Pledges" => "",
      },
      {
        "Account Name" => "DEF Company",
        "Date AFC Signed" => "2026/06/01",
        "Account Region" => "South East",
        "Company Size" => "0-9 Micro",
        "Industry" => "Transportation",
        "Ownership" => "Non-profit",
        "Armed Forces Friendly" => "0",
        "UK Service Veterans And Leavers" => "0",
        "UK Service Spouses And Partners" => "0",
        "Flexible Leave For Spouses" => "Pledged",
        "UK Reservists" => "0",
        "UK Cadets" => "0",
        "Armed Forces Day" => "0",
        "Reserve Forces Day" => "0",
        "Discounts	Armed Forces Charities" => "0",
        "UK Wounded, Injured And Sick" => "Pledged",
        "Bespoke Pledges" => "",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    afc_business_double_abc = instance_double(
      ArmedForcesCovenantBusiness,
      attachments: attachments_double,
      save: true,
      errors: [],
      title: "ABC Company",
    )
    afc_business_double_def = instance_double(
      ArmedForcesCovenantBusiness,
      attachments: attachments_double,
      save: true,
      errors: [],
      title: "DEF Company",
    )
    expect(ArmedForcesCovenantBusiness).to receive(:new).with(
      "title": "DEF Company",
      "summary": generate_summary,
      "body": generate_body("DEF Company", csv_data.second),
      "armed_forces_covenant_business_pledged": %w[flexible-leave-for-spouses uk-wounded-injured-and-sick],
      "armed_forces_covenant_business_region": "south-east",
      "armed_forces_covenant_business_company_size": "micro",
      "armed_forces_covenant_business_industry": "transportation",
      "armed_forces_covenant_business_ownership": "non-profit",
      "armed_forces_covenant_business_date_signed": "2026-06-01",
    ).and_return(afc_business_double_def).ordered
    expect(ArmedForcesCovenantBusiness).to receive(:new).with(
      "title": "ABC Company",
      "summary": generate_summary,
      "body": generate_body("ABC Company", csv_data.first),
      "armed_forces_covenant_business_pledged": %w[armed-forces-friendly uk-service-veterans-and-leavers],
      "armed_forces_covenant_business_region": "wessex",
      "armed_forces_covenant_business_company_size": "large",
      "armed_forces_covenant_business_industry": "healthcare",
      "armed_forces_covenant_business_ownership": "private",
      "armed_forces_covenant_business_date_signed": "2025-06-01",
    ).and_return(afc_business_double_abc).ordered

    expect { task.execute(csv_file_path: csv_path) }.to output(/Saved document: 'DEF Company'.*Saved document: 'ABC Company'.*REPORT.*Imported: 2 document\(s\).*Errors on save: 0 document\(s\).*Skipped: 0 row\(s\)/m).to_stdout
  end

  ["Account Name", "Date AFC Signed", "Account Region", "Company Size", "Industry", "Ownership"]
    .each do |row_column|
    it "throws an error when required field is missing" do
      csv_data = [
        {
          "Account Name" => "ABC Company",
          "Date AFC Signed" => "2025/06/01",
          "Account Region" => "Wessex",
          "Company Size" => "250-500 Large",
          "Industry" => "Healthcare",
          "Ownership" => "Private",
          "Armed Forces Friendly" => "Pledged",
          "UK Service Veterans And Leavers" => "0",
        },
      ]
      csv_data[0][row_column] = nil
      allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)

      expect(ArmedForcesCovenantBusiness).not_to receive(:new)
      expect {
        task.execute(csv_file_path: csv_path)
      }.to raise_error(StandardError, "CSV import failed: 1 row(s) have missing required fields.")
    end
  end

  it "does not save documents in dry run mode" do
    csv_data = [
      {
        "Account Name" => "ABC Company",
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "0",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    afc_business_double = instance_double(
      ArmedForcesCovenantBusiness,
      attachments: attachments_double,
      valid?: true,
      errors: [],
      title: csv_data.first["Account Name"],
    )
    allow(attachments_double).to receive(:build)
    allow(ArmedForcesCovenantBusiness).to receive(:new).and_return(afc_business_double)
    expect(afc_business_double).not_to receive(:save)

    expect {
      task.execute(csv_file_path: csv_path.to_s, dry_run: true)
    }.to output(/\[DRY RUN\] Imported: 1 document\(s\)/).to_stdout
  end

  it "logs the details for invalid rows in dry run mode" do
    csv_data = [
      {
        "Account Name" => "Good Company",
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "0",
      },
      {
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "0",
      },
      {
        "Account Name" => "ABC Company",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "0",
      },
      {
        "Date AFC Signed" => "2025/06/01",
        "Account Name" => "DEF Company",
        "Account Region" => "Wessex",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    afc_business_double = double(save: true, valid?: true, errors: [], title: "Good Company")
    expect(ArmedForcesCovenantBusiness).to receive(:new).once.and_return(afc_business_double)

    expect {
      task.execute(csv_file_path: csv_path.to_s, dry_run: true)
    }.to output(/\[DRY RUN\] Imported: 1 document\(s\).*Skipped: 3 row\(s\).*Line 3: Missing title \(Title: N\/A\).*Line 4: Missing armed_forces_covenant_business_date_signed \(Title: ABC Company\).*Line 5: Missing armed_forces_covenant_business_company_size, armed_forces_covenant_business_industry, armed_forces_covenant_business_ownership \(Title: DEF Company\)/m).to_stdout
  end

  it "logs save errors and final error count" do
    csv_data = [
      {
        "Account Name" => "ABC Company",
        "Date AFC Signed" => "2025/06/01",
        "Account Region" => "Wessex",
        "Company Size" => "250-500 Large",
        "Industry" => "Healthcare",
        "Ownership" => "Private",
        "Armed Forces Friendly" => "Pledged",
        "UK Service Veterans And Leavers" => "Pledged",
        "UK Service Spouses And Partners" => "0",
        "Flexible Leave For Spouses" => "0",
        "UK Reservists" => "0",
        "UK Cadets" => "0",
        "Armed Forces Day" => "0",
        "Reserve Forces Day" => "0",
        "Discounts	Armed Forces Charities" => "0",
        "UK Wounded, Injured And Sick" => "0",
        "Bespoke Pledges" => "-Custom Pledge text",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    stub_any_publishing_api_put_content.and_raise(GdsApi::HTTPErrorResponse.new(422, "Unprocessable Entity"))

    expect {
      task.execute(csv_file_path: csv_path.to_s, dry_run: false)
    }.to output(/Error when saving document: 'ABC Company'.*REPORT.*Imported: 0 document\(s\).*Errors on save: 1 document\(s\).*Skipped: 0 row\(s\)/m).to_stdout
  end
end
