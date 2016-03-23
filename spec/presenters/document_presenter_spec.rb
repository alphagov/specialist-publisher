require 'rails_helper'

describe DocumentPresenter do

  def cma_case_content_item(n)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/cma-cases/example-cma-case-#{n}",
      "title" => "Example CMA Case #{n}",
      "description" => "This is the summary of example CMA case #{n}",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30+00:00",
      "publication_state" => "draft",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [
          {
            "public_timestamp" => "2015-11-23T14:07:47+00:00",
            "note" => "First published."
          }
        ]
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case-#{n}",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  let(:content_item_without_attachments) { cma_case_content_item(0) }

  let(:content_item_with_attachments) { cma_case_content_item(1).deep_merge!({
   "details" => {
     "attachments" => [
       {
         "content_id"=> "77f2d40e-3853-451f-9ca3-a747e8402e34",
         "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
         "content_type"=> "application/jpeg",
         "title"=> "asylum report image title",
         "created_at"=> "2015-12-03T16:59:13+00:00",
         "updated_at"=> "2015-12-03T16:59:13+00:00"
       },
       {
         "content_id"=> "ec3f6901-4156-4720-b4e5-f04c0b152141",
         "url"=> "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
         "content_type"=> "application/pdf",
         "title"=> "asylum report pdf title",
         "created_at"=> "2015-12-03T16:59:13+00:00",
         "updated_at"=> "2015-12-03T16:59:13+00:00"
       }
     ]
   }
  })
  }

  before do
    publishing_api_has_item(content_item_without_attachments)
    publishing_api_has_item(content_item_with_attachments)

    Timecop.freeze(Time.parse("2015-12-03T16:59:13+00:00"))
  end

  after do
    Timecop.return
  end

  describe "#to_json without attachments" do
    let(:specialist_document) { CmaCase.find(content_item_without_attachments["content_id"]) }
    let(:document_presenter) { DocumentPresenter.new(specialist_document) }
    let(:presented_data) { document_presenter.to_json }

    it "is valid against the content schemas" do
      expect(presented_data[:schema_name]).to eq("specialist_document")
      expect(presented_data).to be_valid_against_schema("specialist_document")
    end

    it "does not contain attachments key" do
      expect(presented_data[:attachments]).to be(nil)
    end

    it "returns a specialist document content item" do
      presented_data[:details][:change_history] =  [{public_timestamp: "2015-11-23T14:07:47+00:00", note: "First published." }]
      content_item_without_attachments.delete('publication_state')

      expect(presented_data).to eq(content_item_without_attachments.to_h.deep_symbolize_keys)
    end
  end

  describe "#to_json with attachments" do
    let(:specialist_document) { CmaCase.find(content_item_with_attachments["content_id"]) }
    let(:document_presenter) { DocumentPresenter.new(specialist_document) }
    let(:presented_data) { document_presenter.to_json }

    it "is valid against the content schemas" do
      expect(presented_data[:schema_name]).to eq("specialist_document")
      expect(presented_data).to be_valid_against_schema("specialist_document")
    end

    it "does contain attachments key" do
      expect(presented_data[:details][:attachments].length).to be(2)
    end

    it "returns a specialist document content item" do
      presented_data[:details][:change_history] =  [{public_timestamp: "2015-11-23T14:07:47+00:00", note: "First published." }]
      content_item_with_attachments.delete('publication_state')

      expect(presented_data).to eq(content_item_with_attachments.to_h.deep_symbolize_keys)
    end
  end
end



