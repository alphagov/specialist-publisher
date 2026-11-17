require "rails_helper"

RSpec.describe "bulk_unpublish_documents", type: :task do
  let(:task) { Rake::Task["bulk_unpublish_documents"] }
  let(:csv_path) { Rails.root.join("spec/fixtures/valid_bulk_doc_unpublishing.csv") }
  let(:dry_run) { "false" }

  before(:each) do
    # # stub stdout to reduce noise
    allow($stdout).to receive(:write)
  end

  context "when the CSV data is valid" do
    it "sends an unpublishing request for each item in the CSV file " do
      doc_unpublisher_double = class_double(DocumentUnpublisher, unpublish: nil).as_stubbed_const

      task.execute(csv_file_path: csv_path, dry_run: dry_run)

      expect(doc_unpublisher_double).to have_received(:unpublish).with("1234", "en", "/test-doc-1", "/alt-path-1").ordered
      expect(doc_unpublisher_double).to have_received(:unpublish).with("2345", "en", "/test-doc-2", nil).ordered
    end

    context "when it is a dry run" do
      let(:dry_run) { "true" }
      it "does not attempt to unpublish anything" do
        doc_unpublisher_double = class_double(DocumentUnpublisher, unpublish: nil).as_stubbed_const

        task.execute(csv_file_path: csv_path, dry_run: dry_run)

        expect(doc_unpublisher_double).to_not have_received(:unpublish)
      end
    end
  end

  context "when the CSV data is missing required fields" do
    let(:csv_path) { Rails.root.join("spec/fixtures/invalid_bulk_doc_unpublishing.csv") }

    it "does not attempt to unpublish anything and raises a useful error" do
      doc_unpublisher_double = class_double(DocumentUnpublisher, unpublish: nil).as_stubbed_const

      expect { task.execute(csv_file_path: csv_path, dry_run: dry_run) }.to raise_error(StandardError, "CSV import failed: 1 row(s) have missing required fields.")

      expect(doc_unpublisher_double).to_not have_received(:unpublish)
    end
  end

  context "when a non-existent CSV path is provided" do
    let(:csv_path) { "i-do-not-exist.csv" }

    it "does not attempt to unpublish anything and raises a useful error" do
      doc_unpublisher_double = class_double(DocumentUnpublisher, unpublish: nil).as_stubbed_const

      expect { task.execute(csv_file_path: csv_path, dry_run: dry_run) }.to raise_error(StandardError, "File not found: i-do-not-exist.csv")

      expect(doc_unpublisher_double).to_not have_received(:unpublish)
    end
  end
end
