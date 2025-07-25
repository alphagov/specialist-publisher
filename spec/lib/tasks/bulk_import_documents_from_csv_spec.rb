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
        'Attachment 1', 'file1.pdf', 'http://example.com/file1.pdf',
        '2024-01-01', '2024-01-02'
      ]
    end
    expect(DesignDecision).to receive(:new).with(
      :title => 'Design hearing decision: O/0567/25',
      :summary => 'Outcome of request to invalidate, hearing held on 24 June 2025.',
      :design_decision_litigants => 'Caesar Commerce Ltd v Huizhou New Road Cosmetics Company Limited',
      :design_decision_hearing_officer => 'Arran Cooper',
      :design_decision_british_library_number => 'O/0567/25',
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
$A')
    task.execute(csv_file_path: csv_path.to_s)
  end
  # test for mapping Appointed Person to design_decision_hearing_officer
  # test for managing different permutations of note
end
