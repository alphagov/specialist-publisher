require "publishing_api_finder_publisher"

describe PublishingApiFinderPublisher do
  describe ".call" do
    it "uses GdsApi::PublishingApi to publish the Finders" do
      publishing_api = double("publishing-api")

      metadata = [
        {
          file: {"slug" => "first-finder", "name" => "first finder"},
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {"slug" => "second-finder", "name" => "second finder"},
          timestamp: "2015-01-05T10:45:10.000+00:00",
        }
      ]

      schemae =  [
        {
          file: {"slug" => "first-finder", "facets" => ["a facet", "another facet"] },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {"slug" => "second-finder", "facets" => ["a facet", "another facet"] },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        }
      ]

      expect(GdsApi::PublishingApi).to receive(:new)
        .with(Plek.new.find("publishing-api"))
        .and_return(publishing_api)

      expect(publishing_api).to receive(:put_content_item).twice

      PublishingApiFinderPublisher.new(metadata, schemae).call
    end
  end
end
