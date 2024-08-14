require "rails_helper"

RSpec.describe BusinessFinanceSupportSchemeExportPresenter do
  let(:document) { SpecialistDocument::BusinessFinanceSupportScheme.from_publishing_api(FactoryBot.create(:business_finance_support_scheme)) }
  subject { described_class.new(document) }

  describe ".header_row" do
    it "has the humanized names for the schema fields" do
      expect(described_class.header_row).to eq [
        "Title",
        "Web URL",
        "Summary",
        "Body",
        "Continuation link",
        "Will continue on",
        "Number of employees",
        "Business stage",
        "Industry",
        "Region",
        "Type of support",
      ]
    end
  end

  describe "#row" do
    it "has the same number of fields as the header row" do
      expect(subject.row.length).to eq described_class.header_row.length
    end

    it "includes the title in the correct field" do
      position = described_class.header_row.index("Title")
      expect(subject.row[position]).to eq document.title
    end

    it "includes the public url to the document in the correct field" do
      position = described_class.header_row.index("Web URL")
      expect(subject.row[position]).to eq "#{Plek.website_root}#{document.base_path}"
    end

    it "includes the summary in the correct field" do
      position = described_class.header_row.index("Summary")
      expect(subject.row[position]).to eq document.summary
    end

    it "includes the body in the correct field" do
      position = described_class.header_row.index("Body")
      expect(subject.row[position]).to eq document.body
    end

    it "includes the continuation_link in the correct field" do
      position = described_class.header_row.index("Continuation link")
      expect(subject.row[position]).to eq document.continuation_link
    end

    it "includes the will_continue_on in the correct field" do
      position = described_class.header_row.index("Will continue on")
      expect(subject.row[position]).to eq document.will_continue_on
    end

    it "includes the humanized version of the business_sizes value in the correct field" do
      document.business_sizes = %w[under-10]
      position = described_class.header_row.index("Number of employees")
      expect(subject.row[position]).to eq "0 to 9 employees"
    end

    it "concatenates all values for business_sizes with ;" do
      document.business_sizes = %w[under-10 over-500]
      position = described_class.header_row.index("Number of employees")
      expect(subject.row[position]).to eq "0 to 9 employees;More than 500 employees"
    end

    it "includes the humanized version of the business_stages value in the correct field" do
      document.business_stages = %w[not-yet-trading]
      position = described_class.header_row.index("Business stage")
      expect(subject.row[position]).to eq "Not yet trading"
    end

    it "concatenates all values for business_stages with ;" do
      document.business_stages = %w[not-yet-trading start-up]
      position = described_class.header_row.index("Business stage")
      expect(subject.row[position]).to eq "Not yet trading;Start-ups (1-2 years trading)"
    end

    it "includes the humanized version of the industries value in the correct field" do
      document.industries = %w[agriculture-and-food]
      position = described_class.header_row.index("Industry")
      expect(subject.row[position]).to eq "Agriculture and food"
    end

    it "concatenates all values for industries with ;" do
      document.industries = %w[agriculture-and-food information-technology-digital-and-creative]
      position = described_class.header_row.index("Industry")
      expect(subject.row[position]).to eq "Agriculture and food;IT, digital and creative"
    end

    it "includes the humanized version of the regions value in the correct field" do
      document.regions = %w[northern-ireland]
      position = described_class.header_row.index("Region")
      expect(subject.row[position]).to eq "Northern Ireland"
    end

    it "concatenates all values for regions with ;" do
      document.regions = %w[northern-ireland scotland]
      position = described_class.header_row.index("Region")
      expect(subject.row[position]).to eq "Northern Ireland;Scotland"
    end

    it "includes the humanized version of the types_of_support value in the correct field" do
      document.types_of_support = %w[finance]
      position = described_class.header_row.index("Type of support")
      expect(subject.row[position]).to eq "Finance"
    end

    it "concatenates all values for types_of_support with ;" do
      document.types_of_support = %w[finance recognition-award]
      position = described_class.header_row.index("Type of support")
      expect(subject.row[position]).to eq "Finance;Recognition awards"
    end
  end
end
