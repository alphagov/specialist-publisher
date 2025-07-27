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
  let(:csv_path) { Rails.root.join("publications_export.csv") }

  after(:each) do
    task.reenable
    File.delete(csv_path) if File.exist?(csv_path)
  end

  it "imports documents from a CSV file" do
    CSV.open(csv_path, "w") do |csv|
      csv << %w[
        title
        summary
        body
        attachment_title
        attachment_filename
        attachment_url
        attachment_created_at
        attachment_updated_at
      ]
      csv << [
        "Design hearing decision: O/0567/25",
        '"Outcome of request to invalidate, hearing held on 24 June 2025."',
        '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
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
        "Design Decision O/0567/25",
        "o056725.pdf",
        "http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf",
        "2025-06-26 14:50:48 +0100",
        "2025-06-26 14:50:48 +0100",
      ]
    end
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
    CSV.open(csv_path, "w") do |csv|
      csv << %w[
        title
        summary
        body
        attachment_title
        attachment_filename
        attachment_url
        attachment_created_at
        attachment_updated_at
      ]
      csv << [
        "Design hearing decision: O/1234/56",
        "Outcome of hearing held on 15 July 2025.",
        '| **Litigants** | Some Company Ltd v Other Company Ltd |
| **Appointed Person** | Martin Howe |
Every effort is made to ensure...',
        nil,
        nil,
        nil,
        nil,
        nil,
      ]
    end

    attachments_double = double("attachments")
    allow(attachments_double).to receive(:build)

    design_decision_double = double("DesignDecision", attachments: attachments_double, save: true)

    expect(DesignDecision).to receive(:new).with(
      a_hash_including(design_decision_hearing_officer: "martin-howe"),
    ).and_return(design_decision_double)

    task.execute(csv_file_path: csv_path.to_s)
  end

  it "imports a design decision without creating attachments when no attachment data present" do
    CSV.open(csv_path, "w") do |csv|
      csv << %w[
        title
        summary
        body
        attachment_title
        attachment_filename
        attachment_url
        attachment_created_at
        attachment_updated_at
      ]
      csv << [
        "Design hearing decision: O/9999/88",
        "Outcome of hearing held on 10 August 2025.",
        '| **Litigants** | Example Ltd v Sample Ltd |
| **Hearing Officer** | Martin Howe |

## Note

Every effort is made to ensure design hearing decisions have been accurately recorded.',
        nil, # no attachment_title
        nil, # no attachment_filename
        nil, # no attachment_url
        nil, # no attachment_created_at
        nil, # no attachment_updated_at
      ]
    end
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

  {
    "title" => nil,
    "summary" => nil,
    "body (completely missing)" => nil,
    "body (missing litigants)" => REQUIRED_FIELDS["body_missing_litigants"],
    "body (missing hearing officer)" => REQUIRED_FIELDS["body_missing_hearing_officer"],
  }.each do |case_description, body_value|
    it "skips import when #{case_description} is missing" do
      CSV.open(csv_path, "w") do |csv|
        headers = %w[title summary body] + OPTIONAL_ATTACHMENT_FIELDS.keys
        row = {
          "title" => REQUIRED_FIELDS["title"],
          "summary" => REQUIRED_FIELDS["summary"],
          "body" => REQUIRED_FIELDS["body_with_all"],
        }

        # Override the field being tested
        row["title"] = nil if case_description.include?("title")
        row["summary"] = nil if case_description.include?("summary")
        row["body"] = body_value

        csv << headers
        csv << headers.map { |key| row[key] || OPTIONAL_ATTACHMENT_FIELDS[key] }
      end

      expect(DesignDecision).not_to receive(:new)
      task.execute(csv_file_path: csv_path.to_s)
    end
  end

  it "logs the details for skipped rows" do
    CSV.open(csv_path, "w") do |csv|
      csv << %w[title summary body attachment_title attachment_filename attachment_url attachment_created_at attachment_updated_at]

      # Valid row
      csv << [
        "Design hearing decision: O/1111/25",
        "Outcome of request, hearing held on 20 June 2025.",
        "| **Litigants** | Alpha Ltd v Beta Ltd |\n| **Hearing Officer** | Martin Howe |\n\n## Note\nEvery effort is made...",
        "",
        "",
        "",
        "",
        "",
      ]

      # Invalid row (missing hearing officer)
      csv << [
        "Design hearing decision: O/2222/25",
        "Outcome of request, hearing held on 21 June 2025.",
        "| **Litigants** | Gamma Ltd v Delta Ltd |\n\n## Note\nEvery effort is made...",
        "",
        "",
        "",
        "",
        "",
      ]

      # Invalid row (missing title)
      csv << [
        nil,
        "Outcome of request, hearing held on 22 June 2025.",
        "| **Litigants** | Epsilon Ltd v Zeta Ltd |\n| **Hearing Officer** | Martin Howe |\n\n## Note\nEvery effort is made...",
        "",
        "",
        "",
        "",
        "",
      ]
    end

    design_decision_double = double(save: true)
    expect(DesignDecision).to receive(:new).once.and_return(design_decision_double)

    expect {
      task.execute(csv_file_path: csv_path.to_s)
    }.to output(/Imported: 1 document\(s\).*Skipped: 2 row\(s\).*Line 3: Missing design_decision_hearing_officer.*Line 4: Missing title, design_decision_british_library_number/m).to_stdout
  end

  it "maps hearing officer to schema value and skips invalid officers" do
    CSV.open(csv_path, 'w') do |csv|
      csv << %w[title summary body attachment_title attachment_filename attachment_url attachment_created_at attachment_updated_at]

      # Valid officer
      csv << [
        'Design hearing decision: O/1111/25',
        '"Outcome of hearing held on 10 June 2025."',
        '"| **Litigants** | Test Ltd v Foo Ltd |
      | **Hearing Officer** | Arran Cooper |

      ## Note

      Every effort is made to ensure..."',
        "", "", "", "", ""
      ]

      # Invalid officer
      csv << [
        'Design hearing decision: O/2222/25',
        '"Outcome of hearing held on 11 June 2025."',
        '"| **Litigants** | Test Ltd v Foo Ltd |
      | **Hearing Officer** | Invalid Officer |

      ## Note

      Every effort is made to ensure..."',
        "", "", "", "", ""
      ]
    end

    expect(DesignDecision).to receive(:new).with(hash_including(
                                                   design_decision_hearing_officer: "arran-cooper"
                                                 )).and_return(double(save: true))

    expect {
      task.execute(csv_file_path: csv_path.to_s)
    }.to output(/Imported: 1 document\(s\)\nSkipped: 1 row\(s\)\n\nSkipped row details:\n- Line 3: Missing design_decision_hearing_officer \(Title: Design hearing decision: O\/2222\/25\)/).to_stdout
  end
end
