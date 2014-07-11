require "fast_spec_helper"
require "json"

require "aaib_import_mapper"

RSpec.describe AaibImportMapper do
  subject(:mapper) {
    AaibImportMapper.new(document_creator, repo)
  }

  let(:repo) { double(:repo, store: true) }

  let(:document_creator) { double(:document_creator) }

  let(:raw_data) {
    {
      "original_url" => "http://www.aaib.gov.uk/publications/formal_reports/2_1981_g_baoz.cfm",
      "title" => "2/1981 Cessna 414, G-BAOZ",
      "original_urls" => [
        "http =>//www.aaib.gov.uk/publications/formal_reports/2_1981_g_baoz.cfm"
      ],
      "date_of_occurrence" => "1980-03-23",
      "date_published" => "1234-05-06",
      "registration_string" => "G-BAOZ",
      "registrations" => [
        "G-BAOZ"
      ],
      "aircraft_categories" => [
        "Commercial Air Transport - Fixed Wing"
      ],
      "report_type" => "bulletin",
      "location" => "Near Leeds Bradford Airport",
      "aircraft_types" => "Cessna 414",
      "assets" => [
        {
          "filename" => "downloads/162/2-1981 G-BAOZ.pdf",
          "content_type" => "application/pdf",
          "original_url" => "http://www.aaib.gov.uk/cms_resources/2-1981 G-BAOZ.pdf",
          "original_filename" => "2-1981 G-BAOZ.pdf",
          "title" => "2-1981 G-BAOZ.pdf"
        }
      ],
      "body" => "## Report No: 2/1981. Report on the accident to Cessna 414, G-BAOZ near Leeds\nBradford Airport, 23 March 1980\n\n**Date of occurrence: **23 March 1980\n\n**Location: **   \nNear Leeds Bradford Airport\n\n[ Click here to read full details of this incident](http://www.aaib.gov.uk/pub\nlications/formal_reports/2_1981_g_baoz.cfm)\n\n  \n2/1981 Cessna 414, G-BAOZ\n\n  \nG-BAOZ\n\n  \nCessna 414\n\n  \nNear Leeds Bradford Airport\n\n  \n23 March 1980\n\n  \nCommercial Air Transport - Fixed Wing\n\n  \n![PDF icon](http://www.aaib.gov.uk/sites/maib/_shared/ico_pdf.gif) [2-1981\nG-BAOZ.pdf](http://www.aaib.gov.uk/cms_resources/2-1981%20G-BAOZ.pdf)\n(2,357.43 kb)\n\n"
    }
  }

  let(:transformed_data) {
    {
      title: "2/1981 Cessna 414, G-BAOZ, 23 March 1980",
      summary: "SHOULD BE REMOVED",
      date_of_occurrence: "1980-03-23",
      registration_string: "G-BAOZ",
      registrations: [
        "G-BAOZ"
      ],
      aircraft_category: [
        "Commercial Air Transport - Fixed Wing"
      ],
      report_type: "bulletin",
      location: "Near Leeds Bradford Airport",
      aircraft_types: "Cessna 414",
      body: "## Report No: 2/1981. Report on the accident to Cessna 414, G-BAOZ near Leeds\nBradford Airport, 23 March 1980\n\n**Date of occurrence: **23 March 1980\n\n**Location: **   \nNear Leeds Bradford Airport\n\n[ Click here to read full details of this incident](http://www.aaib.gov.uk/pub\nlications/formal_reports/2_1981_g_baoz.cfm)\n\n  \n2/1981 Cessna 414, G-BAOZ\n\n  \nG-BAOZ\n\n  \nCessna 414\n\n  \nNear Leeds Bradford Airport\n\n  \n23 March 1980\n\n  \nCommercial Air Transport - Fixed Wing\n\n  \n![PDF icon](http://www.aaib.gov.uk/sites/maib/_shared/ico_pdf.gif) [2-1981\nG-BAOZ.pdf](http://www.aaib.gov.uk/cms_resources/2-1981%20G-BAOZ.pdf)\n(2,357.43 kb)\n\n"
    }
  }

  let(:document) { double(:document, valid?: true) }

  it "transforms the raw data into a domain object" do
    expect(document_creator).to receive(:call).with(transformed_data).and_return(document)

    mapper.call(raw_data)
  end
end
