require "publishing_api_finder_publisher"

describe PublishingApiFinderPublisher do
  describe ".call" do
    it "uses GdsApi::PublishingApi to publish the Finders" do
      publishing_api = double("publishing-api")

      metadata = [
        {
          file: {
            "slug" => "first-finder",
            "name" => "first finder",
            "content_id" => "some-random-id",
            "format" => "a_report_format",
            "signup_content_id" => "content-id-for-email-signup-page",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "slug" => "second-finder",
            "name" => "second finder",
            "content_id" => "some-other-random-id",
            "format" => "some_case_format",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        }
      ]

      schemae =  [
        {
          file: {
            "slug" => "first-finder",
            "facets" => ["a facet", "another facet"],
            "document_noun" => "reports",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "slug" => "second-finder",
            "facets" => ["a facet", "another facet"],
            "document_noun" => "cases",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        }
      ]

      expect(GdsApi::PublishingApi).to receive(:new)
        .with(Plek.new.find("publishing-api"))
        .and_return(publishing_api)

      expect(publishing_api).to receive(:put_content_item)
        .with("/first-finder", anything)

      expect(publishing_api).to receive(:put_content_item)
        .with("/first-finder/email-signup", anything)

      expect(publishing_api).to receive(:put_content_item)
        .with("/second-finder", anything)

      PublishingApiFinderPublisher.new(metadata, schemae).call
    end
  end
end
