require "spec_helper"
require "tag_fetcher"
require "gds_api/test_helpers/content_api"
require "webmock/rspec"

describe TagFetcher do

  include GdsApi::TestHelpers::ContentApi

  describe "tag fetching" do

    let(:manual) {
      Manual.new({
        id: "guidance/style-guide",
        slug: "guidance/style-guide",
        title: "Style guide",
        summary: "A summary",
        body: "A body",
        organisation_slug: "cabinet-office",
        state: "draft",
      })
    }

    let(:slug) { "guidance/style-guide" }
    let(:tag_slug) { "government-digital-guidance/content-publishing" }

    before do
      WebMock.disable_net_connect!

      artefact = artefact_for_slug(slug).merge(
        "title" => @title,
        "format" => "manual",
        "details" => {
          "body" => "<p>Body content</p>\n",
          "summary" => "Summary of document",
          "updated_at" => "2014-10-24T08:41:18Z",
          "published_at" => "2014-10-24T08:41:18Z",
        },
        "tags" => [
          {
            "id" => "https://www.gov.uk/api/tags/specialist_sector/government-digital-guidance%2Fcontent-publishing.json",
            "slug" => tag_slug,
            "web_url" => "https://www.gov.uk/topic/government-digital-guidance/content-publishing",
            "title" => "Content and publishing",
          }
        ]
      )

      content_api_has_an_artefact(
        slug,
        artefact
      )
    end

    it "fetches tags for given manual" do
      tags = TagFetcher.new(manual).tags

      expect(tags.map(&:slug)).to eq([tag_slug])
    end

  end

end
