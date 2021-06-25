require "spec_helper"

RSpec.describe DocumentExportPresenter do
  describe ".for" do
    let(:exportable_document) do
      Class.new do
        def self.exportable?
          true
        end

        def self.document_type
          name.underscore
        end
      end
    end

    let(:non_exportable_document) do
      Class.new do
        def self.exportable?
          false
        end

        def self.document_type
          name.underscore
        end
      end
    end

    before do
      stub_const("ExportableDocumentWithExporter", exportable_document)
      stub_const("ExportableDocumentWithExporterExportPresenter", Class.new)
      stub_const("NonExportableDocument", non_exportable_document)
      stub_const("ExportableDocumentWithoutExporter", exportable_document.dup)
    end

    it "returns the ExportPresenter for the supplied document class if it is exportable" do
      expect(described_class.for(ExportableDocumentWithExporter)).to eq(ExportableDocumentWithExporterExportPresenter)
    end

    it "raises NotExportableError if the supplied document class is not exportable" do
      expect {
        described_class.for(NonExportableDocument)
      }.to raise_error(described_class::NotExportableError)
    end

    it "raises NotExportableError if the supplied document class is exportable, but has no ExportPresenter" do
      expect {
        described_class.for(ExportableDocumentWithoutExporter)
      }.to raise_error(described_class::NotExportableError)
    end
  end
end
