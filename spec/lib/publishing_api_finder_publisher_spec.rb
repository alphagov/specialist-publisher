require "publishing_api_finder_publisher"

describe PublishingApiFinderPublisher do
  describe ".call" do
    it "uses GdsApi::PublishingApi to publish the Finders" do
      publishing_api = double("publishing-api")

      metadata = [
        {
          file: {
            "base_path" => "/first-finder",
            "name" => "first finder",
            "format_name" => "first finder things",
            "content_id" => "some-random-id",
            "format" => "a_report_format",
            "signup_content_id" => "content-id-for-email-signup-page",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "base_path" => "/second-finder",
            "name" => "second finder",
            "format_name" => "second finder things",
            "content_id" => "some-other-random-id",
            "format" => "some_case_format",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        }
      ]

      schemae =  [
        {
          file: {
            "facets" => ["a facet", "another facet"],
            "document_noun" => "reports",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
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

    it "doesn't publish a Finder without a content id" do
      metadata = [
        {
          file: {
            "base_path" => "/finder-without-content-id",
            "name" => "finder without content id",
            "format" => "a_report_format",
            "format_name" => "a report format",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "base_path" => "/finder-with-content-id",
            "name" => "finder with content id",
            "content_id" => "some-random-id",
            "format" => "a_report_format",
            "format_name" => "a report format",
            "signup_content_id" => "content-id-for-email-signup-page",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
      ]

      schemae =  [
        {
          file: {
            "facets" => ["a facet", "another facet"],
            "document_noun" => "reports",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "facets" => ["a facet", "another facet"],
            "document_noun" => "reports",
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
      ]

      publishing_api = double("publishing-api")

      expect(GdsApi::PublishingApi).to receive(:new)
        .with(Plek.new.find("publishing-api"))
        .and_return(publishing_api)

      expect(publishing_api).not_to receive(:put_content_item)
        .with("/finder-without-content-id", anything)

      expect(publishing_api).to receive(:put_content_item)
        .with("/finder-with-content-id", anything)

      PublishingApiFinderPublisher.new(metadata, schemae).call
    end
  end
end
