require 'spec_helper'

RSpec.describe AttachmentUploader do
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
      "public_updated_at" => "2015-11-16T11:53:30",
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
        "change_history" => [],
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
  
  let(:cma_cases) { 2.times.map { |n| cma_case_content_item(n) } }

  before do
    cma_cases[1]["details"].merge!(
      "attachments" => [
        {
          "content_id"=> "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
          "content_type"=> "application/jpeg",
          "title"=> "asylum report image title",
          "created_at"=> "2015-12-18T10:12:26+00:00",
          "updated_at"=> "2015-12-18T10:12:26+00:00"
        },
        {
          "content_id"=> "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "url"=> "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
          "content_type"=> "application/pdf",
          "title"=> "asylum report pdf title",
          "created_at"=> "2015-12-18T10:12:26+00:00",
          "updated_at"=> "2015-12-18T10:12:26+00:00"
        }
      ]
    )

    cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  describe "uploader" do
    subject { described_class.new(publisher: publisher) }
    let(:url) { '/uploaded/document.jpg' }

    let(:service) { double("service", create_asset: double("file", file_url: url)) }
    let(:publisher) { double("publisher", services: service) }
    
    let(:attachment) { Attachment.new(changed: false) }
    let(:document) { CmaCase.find(cma_cases[0]["content_id"]) }

    context 'uploading new attachment' do
      it "attachment should not be changed" do
        subject.upload(attachment, document)
        expect(attachment.changed?).to be(false)
      end

      it "sets the attachment url" do
        subject.upload(attachment, document)
        expect(attachment.url).to eq(url)
      end

      it "document attachemnt should be changed" do
        expect(document.attachments).to_not be
        subject.upload(attachment, document)
        expect(document.attachments).to eq([attachment])
      end
    end

    context "editing an existing attachment" do
      let(:document) { CmaCase.find(cma_cases[1]["content_id"]) }
      let(:attachment) { document.attachments.first }

      it "document attachemnt should be changed" do
        attachment.changed = true
        expect(document.attachments.count).to eq(2)
        subject.upload(attachment, document)
        expect(document.attachments.count).to eq(2)
      end
    end

    context 'publisher raises an error' do
      before do
        allow(service).to receive(:create_asset).and_raise(GdsApi::BaseError)
      end

      it 'returns false' do
        expect(subject.upload(attachment, document)).to be(false)
      end
    end
  end
end
