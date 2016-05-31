require 'spec_helper'

RSpec.describe AttachmentUploader do
  context 'for a CMA case document' do
    let(:cma_cases) {
      [
        FactoryGirl.create(:cma_case),
        FactoryGirl.create(:cma_case,
          details: {
            "attachments" => [
              {
                "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
                "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
                "content_type" => "application/jpeg",
                "title" => "asylum report image title",
                "created_at" => "2015-12-18T10:12:26+00:00",
                "updated_at" => "2015-12-18T10:12:26+00:00"
              },
              {
                "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
                "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
                "content_type" => "application/pdf",
                "title" => "asylum report pdf title",
                "created_at" => "2015-12-18T10:12:26+00:00",
                "updated_at" => "2015-12-18T10:12:26+00:00"
              }
            ]
          }),
      ]
    }

    before do
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

  context 'for a manual section' do
    let(:manual) { Payloads.manual_content_item }
    let(:manual_links) { Payloads.manual_links }
    let(:sections) { Payloads.section_content_items }
    let(:section_links) { Payloads.section_links }

    before do
      sections[1]["details"].merge!(
        "attachments" => [
          {
            "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
            "content_type" => "application/jpeg",
            "title" => "asylum report image title",
            "created_at" => "2015-12-18T10:12:26+00:00",
            "updated_at" => "2015-12-18T10:12:26+00:00"
          },
          {
            "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
            "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
            "content_type" => "application/pdf",
            "title" => "asylum report pdf title",
            "created_at" => "2015-12-18T10:12:26+00:00",
            "updated_at" => "2015-12-18T10:12:26+00:00"
          }
        ]
      )

      publishing_api_has_item(manual)
      publishing_api_has_links(manual_links)
      sections.each do |section|
        publishing_api_has_item(section)
      end
      section_links.each do |section_linkset|
        publishing_api_has_links(section_linkset)
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
      let(:section) { Section.find(content_id: sections[0]["content_id"]) }

      context 'uploading new attachment' do
        it "attachment should not be changed" do
          subject.upload(attachment, section)
          expect(attachment.changed?).to be(false)
        end

        it "sets the attachment url" do
          subject.upload(attachment, section)
          expect(attachment.url).to eq(url)
        end

        it "document attachemnt should be changed" do
          expect(section.attachments).to_not be
          subject.upload(attachment, section)
          expect(section.attachments).to eq([attachment])
        end
      end

      context "editing an existing attachment" do
        let(:section) { Section.find(content_id: sections[1]["content_id"]) }
        let(:attachment) { section.attachments.first }

        it "section attachemnt should be changed" do
          attachment.changed = true
          expect(section.attachments.count).to eq(2)
          subject.upload(attachment, section)
          expect(section.attachments.count).to eq(2)
        end
      end

      context 'publisher raises an error' do
        before do
          allow(service).to receive(:create_asset).and_raise(GdsApi::BaseError)
        end

        it 'returns false' do
          expect(subject.upload(attachment, section)).to be(false)
        end
      end
    end
  end
end
