require "spec_helper"

RSpec.describe DocumentExportPresenter do
  describe "#header_row" do
    presenter = DocumentExportPresenter.new(BusinessFinanceSupportScheme)

    it "has the humanized names for the common and finder-specific fields" do
      expect(presenter.header_row).to eq([
        "Locale",
        "Base path",
        "Title",
        "Summary",
        "Body",
        "Publication state",
        "Types of support",
        "Business stages",
        "Industries",
        "Business sizes",
        "Regions",
        "Continuation link",
        "Will continue on",
      ])
    end
  end

  describe "#parse_document" do
    subject { DocumentExportPresenter.new(BusinessFinanceSupportScheme) }
    let(:document) { BusinessFinanceSupportScheme.from_publishing_api(FactoryBot.create(:business_finance_support_scheme)) }

    it "has the same number of fields as the header row" do
      expect(subject.parse_document(document).length).to eq subject.header_row.length
    end

    it "includes the locale in the correct place" do
      position = subject.header_row.index("Locale")
      expect(subject.parse_document(document)[position]).to eq document.locale
    end

    it "includes the base path in the correct place" do
      position = subject.header_row.index("Base path")
      expect(subject.parse_document(document)[position]).to eq document.base_path
    end

    it "includes the summary in the correct place" do
      position = subject.header_row.index("Summary")
      expect(subject.parse_document(document)[position]).to eq document.summary
    end

    it "includes the body in the correct place" do
      position = subject.header_row.index("Body")
      expect(subject.parse_document(document)[position]).to eq document.body
    end

    it "includes the publication state in the correct place" do
      position = subject.header_row.index("Publication state")
      expect(subject.parse_document(document)[position]).to eq document.publication_state
    end

    it "includes the humanized version of the types_of_support value in the correct field" do
      document.types_of_support = %w[finance]
      position = subject.header_row.index("Types of support")
      expect(subject.parse_document(document)[position]).to eq "Finance"
    end

    it "concatenates all values for types_of_support with ;" do
      document.types_of_support = %w[finance recognition-award]
      position = subject.header_row.index("Types of support")
      expect(subject.parse_document(document)[position]).to eq "Finance;Recognition awards"
    end

    it "includes the humanized version of the business_stages value in the correct field" do
      document.business_stages = %w[not-yet-trading]
      position = subject.header_row.index("Business stages")
      expect(subject.parse_document(document)[position]).to eq "Not yet trading"
    end

    it "concatenates all values for business_stages with ;" do
      document.business_stages = %w[not-yet-trading start-up]
      position = subject.header_row.index("Business stages")
      expect(subject.parse_document(document)[position]).to eq "Not yet trading;Start-ups (1-2 years trading)"
    end

    it "includes the humanized version of the industries value in the correct field" do
      document.industries = %w[agriculture-and-food]
      position = subject.header_row.index("Industries")
      expect(subject.parse_document(document)[position]).to eq "Agriculture and food"
    end

    it "concatenates all values for industries with ;" do
      document.industries = %w[agriculture-and-food information-technology-digital-and-creative]
      position = subject.header_row.index("Industries")
      expect(subject.parse_document(document)[position]).to eq "Agriculture and food;IT, digital and creative"
    end

    it "includes the humanized version of the business_sizes value in the correct field" do
      document.business_sizes = %w[under-10]
      position = subject.header_row.index("Business sizes")
      expect(subject.parse_document(document)[position]).to eq "0 to 9 employees"
    end

    it "concatenates all values for business_sizes with ;" do
      document.business_sizes = %w[under-10 over-500]
      position = subject.header_row.index("Business sizes")
      expect(subject.parse_document(document)[position]).to eq "0 to 9 employees;More than 500 employees"
    end

    it "includes the humanized version of the regions value in the correct field" do
      document.regions = %w[northern-ireland]
      position = subject.header_row.index("Regions")
      expect(subject.parse_document(document)[position]).to eq "Northern Ireland"
    end

    it "concatenates all values for regions with ;" do
      document.regions = %w[northern-ireland scotland]
      position = subject.header_row.index("Regions")
      expect(subject.parse_document(document)[position]).to eq "Northern Ireland;Scotland"
    end

    it "surfaces the continuation link" do
      document.continuation_link = "https://www.gov.uk"
      position = subject.header_row.index("Continuation link")
      expect(subject.parse_document(document)[position]).to eq "https://www.gov.uk"
    end

    it "surfaces the 'will continue on' field" do
      document.will_continue_on = "on GOV.UK"
      position = subject.header_row.index("Will continue on")
      expect(subject.parse_document(document)[position]).to eq "on GOV.UK"
    end
  end
end
