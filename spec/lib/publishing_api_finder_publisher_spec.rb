require "spec_helper"
require "publishing_api_finder_publisher"

describe PublishingApiFinderPublisher do
  describe ".call" do

    let(:schema) do
      {
        file: {
          "facets" => [
            {
              "key" => "report_type",
              "name" => "Report type",
              "type" => "text",
              "display_as_result_metadata" => true,
              "filterable" => true,
            },
          ],
          "document_noun" => "reports",
        },
        timestamp: "2015-01-05T10:45:10.000+00:00",
      }
    end

    def make_metadata base_path, overrides = {}
      underscore_name = base_path.sub("/", "")
      name = underscore_name.humanize
      metadata = {
        "base_path" => base_path,
        "name" => name,
        "format_name" => "#{name} things",
        "content_id" => SecureRandom.uuid,
        "format" => "#{underscore_name}_format",
        "logo_path" => "http://example.com/logo.png",
      }.merge(overrides)
      metadata.delete("content_id") if metadata["content_id"].nil?

      {
        file: metadata,
        timestamp: "2015-01-05T10:45:10.000+00:00",
      }
    end

    it "uses GdsApi::PublishingApi to publish the Finders" do
      publishing_api = double("publishing-api")

      metadata = [
        make_metadata("/first-finder", "signup_content_id" => SecureRandom.uuid),
        make_metadata("/second-finder")
      ]

      schemae =  [schema, schema]

      expect(GdsApi::PublishingApi).to receive(:new)
        .with(Plek.new.find("publishing-api"))
        .and_return(publishing_api)

      expect(publishing_api).to receive(:put_content_item)
        .with("/first-finder", be_valid_against_schema("finder"))

       # This should be validated against an email-signup schema if one gets created
      expect(publishing_api).to receive(:put_content_item)
        .with("/first-finder/email-signup", anything)

      expect(publishing_api).to receive(:put_content_item)
        .with("/second-finder", be_valid_against_schema("finder"))

      PublishingApiFinderPublisher.new(metadata, schemae).call
    end

    it "doesn't publish a Finder without a content id" do

      metadata = [
        make_metadata("/finder-without-content-id", "content_id" => nil),
        make_metadata("/finder-with-content-id")
      ]

      schemae =  [schema, schema]

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
