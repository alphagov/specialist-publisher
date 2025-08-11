require "rails_helper"

REQUIRED_FIELDS = {
  "title" => "Design hearing decision: O/9999/25",
  "summary" => "Outcome of hearing held on 15 July 2025.",
  "body_with_all" => <<~BODY,
    | **Litigants** | Some Company Ltd v Other Company Ltd |
    | **Hearing Officer** | Martin Howe |

    ## Note

    Every effort is made to ensure design hearing decisions are correct.
  BODY
  "body_missing_litigants" => <<~BODY,
    | **Hearing Officer** | Martin Howe |

    ## Note

    Every effort is made to ensure design hearing decisions are correct.
  BODY
  "body_missing_hearing_officer" => <<~BODY,
    | **Litigants** | Some Company Ltd v Other Company Ltd |

    ## Note

    Every effort is made to ensure design hearing decisions are correct.
  BODY
  "body_invalid_hearing_officer" => <<~BODY,
    | **Hearing Officer** | Invalid Officer |

    ## Note

    Every effort is made to ensure design hearing decisions are correct.
  BODY
}.freeze

OPTIONAL_ATTACHMENT_FIELDS = {
  "attachment_title" => "Design Decision O/9999/25",
  "attachment_filename" => "o999925.pdf",
  "attachment_url" => "http://example.com/o999925.pdf",
  "attachment_created_at" => "2025-07-16 10:00:00",
  "attachment_updated_at" => "2025-07-16 10:00:00",
}.freeze

RSpec.describe "bulk_import_documents_from_csv", type: :task do
  let(:task) { Rake::Task["bulk_import_documents_from_csv"] }
  let(:csv_path) { "dummy_path.csv" }

  before(:each) do
    # stub stdout to reduce noise
    allow($stdout).to receive(:write)
    allow(File).to receive(:exist?).with(csv_path).and_return(true)
  end

  after(:each) do
    task.reenable
  end

  it "imports documents from a CSV file" do
    csv_data = [{
      "title" => "Design hearing decision: O/0567/25",
      "summary" => '"Outcome of request to invalidate, hearing held on 24 June 2025."',
      "body" => '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
| **Hearing Officer** | Arran Cooper |

## Note

Every effort is made to ensure design hearing decisions have been accurately recorded, but some errors may have been introduced during conversion for the web.

Copies of any documents annexed to a decision are available from:

$A
Tribunal Section,
Intellectual Property Office,
Concept House,
Cardiff Road,
Newport,
South Wales
NP10 8QQ
$A"',
      "attachment_title" => "Design Decision O/0567/25",
      "attachment_filename" => "o056725.pdf",
      "attachment_url" => "http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf",
      "attachment_created_at" => "2025-06-26 14:50:48 +0100",
      "attachment_updated_at" => "2025-06-26 14:50:48 +0100",
    }]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    design_decision_double = instance_double(
      DesignDecision,
      attachments: attachments_double,
      save: true,
    )
    expect(attachments_double).to receive(:build).with(
      title: "Design Decision O/0567/25",
      filename: "o056725.pdf",
      url: "http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf",
      content_type: "application/pdf",
      created_at: Time.zone.parse("2025-06-26 14:50:48 +0100"),
      updated_at: Time.zone.parse("2025-06-26 14:50:48 +0100"),
    )
    expect(DesignDecision).to receive(:new).with(
      title: "Design hearing decision: O/0567/25",
      summary: "Outcome of request to invalidate, hearing held on 24 June 2025.",
      design_decision_litigants: "Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited",
      design_decision_hearing_officer: "arran-cooper",
      design_decision_british_library_number: "O/0567/25",
      design_decision_date: "2025-06-24",
      body: 'Every effort is made to ensure design hearing decisions have been accurately recorded, but some errors may have been introduced during conversion for the web.

Copies of any documents annexed to a decision are available from:

$A
Tribunal Section,
Intellectual Property Office,
Concept House,
Cardiff Road,
Newport,
South Wales
NP10 8QQ
$A',
    ).and_return(design_decision_double)

    task.execute(csv_file_path: csv_path.to_s)
  end

  it "imports documents in reverse order" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/0567/25",
        "summary" => '"Outcome of request to invalidate, hearing held on 24 June 2025."',
        "body" => '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
| **Hearing Officer** | Arran Cooper |',
      },
      {
        "title" => "Design hearing decision: O/0567/26",
        "summary" => '"Outcome of request to invalidate, hearing held on 24 June 2025."',
        "body" => '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
| **Hearing Officer** | Arran Cooper |',
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    design_decision_double = instance_double(
      DesignDecision,
      attachments: attachments_double,
      save: true,
    )
    expect(DesignDecision).to receive(:new).with(
      title: "Design hearing decision: O/0567/26",
      summary: "Outcome of request to invalidate, hearing held on 24 June 2025.",
      design_decision_litigants: "Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited",
      design_decision_hearing_officer: "arran-cooper",
      design_decision_british_library_number: "O/0567/26",
      design_decision_date: "2025-06-24",
      body: "Missing note body",
    ).and_return(design_decision_double).ordered
    expect(DesignDecision).to receive(:new).with(
      title: "Design hearing decision: O/0567/25",
      summary: "Outcome of request to invalidate, hearing held on 24 June 2025.",
      design_decision_litigants: "Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited",
      design_decision_hearing_officer: "arran-cooper",
      design_decision_british_library_number: "O/0567/25",
      design_decision_date: "2025-06-24",
      body: "Missing note body",
    ).and_return(design_decision_double).ordered
    task.execute(csv_file_path: csv_path.to_s)
  end

  it "extracts design_decision_hearing_officer from Appointed Person when Hearing Officer is absent" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/1234/56",
        "summary" => "Outcome of hearing held on 15 July 2025.",
        "body" => '| **Litigants** | Some Company Ltd v Other Company Ltd |
| **Appointed Person** | Martin Howe |
Every effort is made to ensure...',
        "attachment_title" => nil,
        "attachment_filename" => nil,
        "attachment_url" => nil,
        "attachment_created_at" => nil,
        "attachment_updated_at" => nil,
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    allow(attachments_double).to receive(:build)
    design_decision_double = double("DesignDecision", attachments: attachments_double, save: true)
    expect(DesignDecision).to receive(:new).with(
      a_hash_including(design_decision_hearing_officer: "martin-howe"),
    ).and_return(design_decision_double)

    task.execute(csv_file_path: csv_path.to_s)
  end

  it "imports a design decision without creating attachments when no attachment data present" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/9999/88",
        "summary" => "Outcome of hearing held on 10 August 2025.",
        "body" => '| **Litigants** | Example Ltd v Sample Ltd |
| **Hearing Officer** | Martin Howe |

## Note

Every effort is made to ensure design hearing decisions have been accurately recorded.',
        "attachment_title" => nil,
        "attachment_filename" => nil,
        "attachment_url" => nil,
        "attachment_created_at" => nil,
        "attachment_updated_at" => nil,
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    design_decision_double = instance_double("DesignDecision", attachments: [], save: true)
    expect(DesignDecision).to receive(:new).with(
      hash_including(
        title: "Design hearing decision: O/9999/88",
        design_decision_litigants: "Example Ltd v Sample Ltd",
        design_decision_hearing_officer: "martin-howe",
        design_decision_british_library_number: "O/9999/88",
        design_decision_date: "2025-08-10",
      ),
    ).and_return(design_decision_double)
    expect(design_decision_double.attachments).not_to receive(:build)
    expect(design_decision_double).to receive(:save)

    task.execute(csv_file_path: csv_path.to_s)
  end

  it "reports on missing attachments and notes" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/9999/88",
        "summary" => "Outcome of hearing held on 10 August 2025.",
        "body" => '| **Litigants** | Example Ltd v Sample Ltd |
| **Hearing Officer** | Martin Howe |',
        "attachment_title" => nil,
        "attachment_filename" => nil,
        "attachment_url" => nil,
        "attachment_created_at" => nil,
        "attachment_updated_at" => nil,
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    design_decision_double = instance_double("DesignDecision", attachments: [], save: true)
    expect(DesignDecision).to receive(:new).with(
      hash_including(
        title: "Design hearing decision: O/9999/88",
        design_decision_litigants: "Example Ltd v Sample Ltd",
        design_decision_hearing_officer: "martin-howe",
        design_decision_british_library_number: "O/9999/88",
        design_decision_date: "2025-08-10",
      ),
    ).and_return(design_decision_double)
    expect(design_decision_double.attachments).not_to receive(:build)
    expect(design_decision_double).to receive(:save)

    expect {
      task.execute(csv_file_path: csv_path.to_s)
    }.to output(/Imported: 1 document\(s\).*Skipped: 0 row\(s\).*Fix up: 1 row\(s\).*Fix up row details:.*Line 2: Fix up attachment, note/m).to_stdout
  end

  {
    "title is missing" => nil,
    "summary is missing" => nil,
    "body (completely missing)" => nil,
    "body (missing litigants)" => REQUIRED_FIELDS["body_missing_litigants"],
    "body (missing hearing officer)" => REQUIRED_FIELDS["body_missing_hearing_officer"],
    "body (hearing officer does not map to schema)" => REQUIRED_FIELDS["body_invalid_hearing_officer"],
  }.each do |case_description, body_value|
    it "throws an error when #{case_description}" do
      row = {
        "title" => REQUIRED_FIELDS["title"],
        "summary" => REQUIRED_FIELDS["summary"],
        "body" => REQUIRED_FIELDS["body_with_all"],
      }.merge(OPTIONAL_ATTACHMENT_FIELDS)
      # Override the field being tested
      row["title"] = nil if case_description.include?("title")
      row["summary"] = nil if case_description.include?("summary")
      row["body"] = body_value
      allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return([row].each)
      expect(DesignDecision).not_to receive(:new)

      expect {
        task.execute(csv_file_path: csv_path.to_s)
      }.to raise_error(StandardError, "CSV import failed: 1 row(s) have missing required fields.")
    end
  end

  it "does not save documents in dry run mode" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/0567/25",
        "summary" => '"Outcome of request to invalidate, hearing held on 24 June 2025."',
        "body" => '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
| **Hearing Officer** | Arran Cooper |

## Note

Every effort is made to ensure design hearing decisions have been accurately recorded"',
        "attachment_title" => "Design Decision O/0567/25",
        "attachment_filename" => "o056725.pdf",
        "attachment_url" => "http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf",
        "attachment_created_at" => "2025-06-26 14:50:48 +0100",
        "attachment_updated_at" => "2025-06-26 14:50:48 +0100",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    design_decision_double = instance_double(
      DesignDecision,
      attachments: attachments_double,
    )
    allow(attachments_double).to receive(:build)
    allow(DesignDecision).to receive(:new).and_return(design_decision_double)
    expect(design_decision_double).not_to receive(:save)

    expect {
      task.execute(csv_file_path: csv_path.to_s, dry_run: true)
    }.to output(/\[DRY RUN\] Imported: 1 document\(s\)/).to_stdout
  end

  it "logs the details for invalid rows in dry run mode" do
    csv_data = [
      {
        "title" => "Design hearing decision: O/1111/25",
        "summary" => "Outcome of request, hearing held on 20 June 2025.",
        "body" => "| **Litigants** | Alpha Ltd v Beta Ltd |\n| **Hearing Officer** | Martin Howe |\n\n## Note\nEvery effort is made...",
        "attachment_title" => "",
        "attachment_filename" => "",
        "attachment_url" => "",
        "attachment_created_at" => "",
        "attachment_updated_at" => "",
      },
      {
        "title" => "Design hearing decision: O/2222/25",
        "summary" => "Outcome of request, hearing held on 21 June 2025.",
        "body" => "| **Litigants** | Gamma Ltd v Delta Ltd |\n\n## Note\nEvery effort is made...",
        "attachment_title" => "",
        "attachment_filename" => "",
        "attachment_url" => "",
        "attachment_created_at" => "",
        "attachment_updated_at" => "",
      },
      {
        "title" => nil,
        "summary" => "Outcome of request, hearing held on 22 June 2025.",
        "body" => "| **Litigants** | Epsilon Ltd v Zeta Ltd |\n| **Hearing Officer** | Martin Howe |\n\n## Note\nEvery effort is made...",
        "attachment_title" => "",
        "attachment_filename" => "",
        "attachment_url" => "",
        "attachment_created_at" => "",
        "attachment_updated_at" => "",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    design_decision_double = double(save: true)
    expect(DesignDecision).to receive(:new).once.and_return(design_decision_double)

    expect {
      task.execute(csv_file_path: csv_path.to_s, dry_run: true)
    }.to output(/\[DRY RUN\] Imported: 1 document\(s\).*Skipped: 2 row\(s\).*Line 3: Missing design_decision_hearing_officer.*Line 4: Missing title, design_decision_british_library_number/m).to_stdout
  end

  it "uses an optional mapping CSV for hearing officers" do
    mapping_csv_path = "mapping_file.csv"
    allow(File).to receive(:exist?).with(mapping_csv_path).and_return(true)
    mapping_data = [
      { "label" => "Mr Martin Howe KC", "value" => "martin-howe" },
      { "label" => "A Cooper", "value" => "arran-cooper" },
    ]
    allow(CSV).to receive(:foreach).with(mapping_csv_path, headers: true) do |&block|
      mapping_data.each { |row| block.call(row) }
    end
    csv_data = [
      {
        "title" => "Design hearing decision: O/0567/25",
        "summary" => '"Outcome of request to invalidate, hearing held on 24 June 2025."',
        "body" => '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
| **Hearing Officer** | A Cooper |

## Note

Every effort is made to ensure design hearing decisions have been accurately recorded"',
        "attachment_title" => "Design Decision O/0567/25",
        "attachment_filename" => "o056725.pdf",
        "attachment_url" => "http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf",
        "attachment_created_at" => "2025-06-26 14:50:48 +0100",
        "attachment_updated_at" => "2025-06-26 14:50:48 +0100",
      },
    ]
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_return(csv_data.each)
    attachments_double = double("attachments")
    design_decision_double = instance_double(
      DesignDecision,
      attachments: attachments_double,
      save: true,
    )
    allow(attachments_double).to receive(:build)
    expect(DesignDecision).to receive(:new).with(
      hash_including(design_decision_hearing_officer: "arran-cooper"),
    ).and_return(design_decision_double)

    task.execute(csv_file_path: csv_path.to_s, mapping_file_path: mapping_csv_path)
  end
end
