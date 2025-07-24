require "rails_helper"

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
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_yield(csv_data.first)
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
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_yield(csv_data.first)
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
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_yield(csv_data.first)
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
end
