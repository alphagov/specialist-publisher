require 'spec_helper'

RSpec.describe GovspeakPresenter do
  let(:specialist_document) { CmaCase.from_publishing_api(payload) }
  let(:govspeak_presenter) { GovspeakPresenter.new(specialist_document) }
  let(:presented_data) { govspeak_presenter.present }

  describe "#present" do
    context "without attachments" do
      let(:payload) {
        FactoryGirl.create(:cma_case,
          details: {
            body: [{
              "content_type" => "text/govspeak",
              "content" => "^callout test^",
            }],
          })
      }

      it "should render html and Govspeak when a Govspeak string is provided" do
        input_govspeak = "^callout test^"
        rendered_html = "\n<div role=\"note\" aria-label=\"Information\" "\
                        "class=\"application-notice info-notice\">\n"\
                        "<p>callout test</p>\n</div>\n"
        presented_content = [{ content_type: "text/govspeak", content: input_govspeak },
                             { content_type: "text/html", content: rendered_html }]

        expect(presented_data).to eq(presented_content)
      end
    end

    context "with attachments" do
      let(:payload) {
        FactoryGirl.create(:cma_case,
          details: {
            body: [{
              "content_type" => "text/govspeak",
              "content" => "[InlineAttachment:asylum-support-image.jpg]",
            }],
            attachments: [
              {
                "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
                "url" => "https://assets.publishing.service.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
                "content_type" => "application/jpeg",
                "title" => "asylum report image title",
                "created_at" => "2015-12-03T16:59:13+00:00",
                "updated_at" => "2015-12-03T16:59:13+00:00"
              },
              {
                "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
                "url" => "https://assets.publishing.service.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
                "content_type" => "application/pdf",
                "title" => "asylum report pdf title",
                "created_at" => "2015-12-03T16:59:13+00:00",
                "updated_at" => "2015-12-03T16:59:13+00:00"
              }
            ]
          })
      }

      it "does not change the govspeak snippet" do
        presented_govspeak = presented_data.find { |r| r[:content_type] == "text/govspeak" }[:content]
        attachment_snippet = "[InlineAttachment:asylum-support-image.jpg]"

        expect(presented_govspeak).to eq(attachment_snippet)
      end


      it "expands the attachment snippet to a non-external html link" do
        presented_html = presented_data.find { |r| r[:content_type] == "text/html" }[:content]
        expected_html = "<p><a href=\"https://assets.publishing.service.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg\">asylum report image title</a></p>\n"

        expect(presented_html).to eq(expected_html)
      end

      context "when the html uses spaces instead of underscores for InlineAttachment" do
        let(:payload) {
          FactoryGirl.create(:cma_case,
            details: {
              body: [{
                "content_type" => "text/govspeak",
                "content" => "[InlineAttachment:asylum support image.jpg]",
              }],
              attachments: [
                {
                  "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
                  "url" => "https://an.external.link.uk/media/513a0efbed915d425e000002/asylum_support_image.jpg",
                  "content_type" => "application/jpeg",
                  "title" => "asylum report image title",
                  "created_at" => "2015-12-03T16:59:13+00:00",
                  "updated_at" => "2015-12-03T16:59:13+00:00"
                },
              ]
            })
        }

        it "expands the attachment snippet to an external html link" do
          presented_html = presented_data.find { |r| r[:content_type] == "text/html" }[:content]
          expected_html = "<p><a rel=\"external\" href=\"https://an.external.link.uk/media/513a0efbed915d425e000002/asylum_support_image.jpg\">asylum report image title</a></p>\n"

          expect(presented_html).to eq(expected_html)
        end
      end
    end
  end
end
