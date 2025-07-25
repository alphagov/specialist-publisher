require "rails_helper"

RSpec.describe "bulk_import_documents_from_csv", type: :task do
  let(:task) { Rake::Task["bulk_import_documents_from_csv"] }
  let(:csv_path) { Rails.root.join("publications_export.csv") }

  after(:each) do
    task.reenable
    File.delete(csv_path) if File.exist?(csv_path)
  end

  it "imports documents from a CSV file" do
    CSV.open(csv_path, 'w') do |csv|
      csv << %w[
        title summary body
        attachment_title attachment_filename attachment_url
        attachment_created_at attachment_updated_at
      ]
      csv << [
        'Design hearing decision: O/0567/25', '"Outcome of request to invalidate, hearing held on 24 June 2025."', '"| **Litigants** | Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited |
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
        'Design Decision O/0567/25', 'o056725.pdf', 'http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf',
        '2025-06-26 14:50:48 +0100', '2025-06-26 14:50:48 +0100'
      ]
    end
    attachments_double = double("attachments")
    design_decision_double = instance_double(
      DesignDecision,
      attachments: attachments_double,
      save: true
    )

    expect(attachments_double).to receive(:build).with(
      title: 'Design Decision O/0567/25',
      filename: 'o056725.pdf',
      url: 'http://asset-manager.dev.gov.uk/media/685d5038f85b4b993fd752dd/o056725.pdf',
      created_at: Time.zone.parse('2025-06-26 14:50:48 +0100'),
      updated_at: Time.zone.parse('2025-06-26 14:50:48 +0100')
    )

    expect(DesignDecision).to receive(:new).with(
      :title => 'Design hearing decision: O/0567/25',
      :summary => 'Outcome of request to invalidate, hearing held on 24 June 2025.',
      :design_decision_litigants => 'Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited',
      :design_decision_hearing_officer => 'Arran Cooper',
      :design_decision_british_library_number => 'O/0567/25',
      :design_decision_date => '2025-06-24',
      :body => 'Every effort is made to ensure design hearing decisions have been accurately recorded, but some errors may have been introduced during conversion for the web.

Copies of any documents annexed to a decision are available from:

$A
Tribunal Section,
Intellectual Property Office,
Concept House,
Cardiff Road,
Newport,
South Wales
NP10 8QQ
$A').and_return(design_decision_double)
    task.execute(csv_file_path: csv_path.to_s)
  end
  # test for mapping Appointed Person to design_decision_hearing_officer
  # test if any properties are nil then do not import, record the number not imported
  # test for no attachments
end
