require "spec_helper"

RSpec.describe DocumentExportPresenter do
  describe ".for" do
    class ExportableDocumentWithExporter
      def self.exportable?
        true
      end

      def self.document_type
        name.underscore
      end
    end

    class ExportableDocumentWithExporterExportPresenter
    end

    class NonExportableDocument
      def self.exportable?
        false
      end

      def self.document_type
        name.underscore
      end
    end

    class ExportableDocumentWithoutExporter
      def self.exportable?
        false
      end

      def self.document_type
        name.underscore
      end
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
