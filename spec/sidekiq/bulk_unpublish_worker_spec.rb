require "rails_helper"

RSpec.describe BulkUnpublishWorker do
  let(:user) { FactoryBot.create(:gds_editor) }
  let(:csv_input) { "base_path,alternative_path\n/cma-cases/one,\n" }
  let(:unpublisher) do
    instance_double(BulkDocumentUnpublisher, validate: nil, valid?: true, call: [], rows: [])
  end

  before do
    allow(BulkDocumentUnpublisher).to receive(:new).and_return(unpublisher)
  end

  describe "perform" do
    it "validates the CSV and then unpublishes the documents in it" do
      subject.perform(CmaCase.admin_slug, user.id, csv_input)

      expect(BulkDocumentUnpublisher).to have_received(:new).with(CmaCase, csv_input)
      expect(unpublisher).to have_received(:validate)
      expect(unpublisher).to have_received(:call)
    end

    it "raises an error if the user is no longer a GDS editor" do
      user.update(permissions: %w[signin editor])

      expect { subject.perform(CmaCase.admin_slug, user.id, csv_input) }
        .to raise_error(Pundit::NotAuthorizedError)

      expect(unpublisher).not_to have_received(:call)
    end

    it "raises an error without unpublishing anything if the CSV is no longer valid" do
      allow(unpublisher).to receive(:valid?).and_return(false)
      allow(unpublisher).to receive(:errors).and_return(["Document not found: /cma-cases/one"])

      expect { subject.perform(CmaCase.admin_slug, user.id, csv_input) }
        .to raise_error(BulkUnpublishWorker::InvalidCsvError, "Document not found: /cma-cases/one")

      expect(unpublisher).not_to have_received(:call)
    end

    it "raises an error if the document type no longer exists" do
      expect { subject.perform("not-a-document-type", user.id, csv_input) }
        .to raise_error(ArgumentError, "Unknown document type: not-a-document-type")

      expect(unpublisher).not_to have_received(:call)
    end
  end
end
