require "spec_helper"
require "rummager_finder_publisher"

describe RummagerFinderPublisher do
  let(:rummager) { double }

  let(:test_logger) { Logger.new(nil) }

  describe ".call" do
    it "uses GdsApi::Rummager to publish the Finders" do
      metadata = [
        {
          file: {
            "base_path" => "/first-finder",
            "name" => "first finder",
            "format_name" => "first finder things",
            "description" => "first finder description",
            "content_id" => SecureRandom.uuid,
            "format" => "a_report_format",
            "signup_content_id" => SecureRandom.uuid,
            "logo_path" => "http://example.com/logo.png",
            "topics" => [
              "business-tax/paye",
            ],
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
        {
          file: {
            "base_path" => "/second-finder",
            "name" => "second finder",
            "format_name" => "second finder things",
            "content_id" => SecureRandom.uuid,
            "format" => "some_case_format",
            "logo_path" => "http://example.com/logo.png",
            "topics" => [
              "competition/mergers",
              "competition/markets",
            ],
          },
          timestamp: "2015-02-14T11:43:23.000+00:00",
        }
      ]

      expect(GdsApi::Rummager).to receive(:new)
        .with(Plek.new.find("rummager"))
        .and_return(rummager)

      expect(rummager).to receive(:add_document)
        .with("edition", "/first-finder", {
          "title" => "first finder",
          "description" => "first finder description",
          "link" => "/first-finder",
          "format" => "finder",
          "public_timestamp" => "2015-01-05T10:45:10.000+00:00",
          "specialist_sectors" => [
            "business-tax/paye",
          ]
        })

      expect(rummager).to receive(:add_document)
        .with("edition", "/second-finder", {
          "title" => "second finder",
          "description" => "",
          "link" => "/second-finder",
          "format" => "finder",
          "public_timestamp" => "2015-02-14T11:43:23.000+00:00",
          "specialist_sectors" => [
            "competition/mergers",
            "competition/markets",
          ],
        })

      RummagerFinderPublisher.new(metadata, logger: test_logger).call
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
            "signup_content_id" => SecureRandom.uuid,
          },
          timestamp: "2015-01-05T10:45:10.000+00:00",
        },
      ]

      expect(GdsApi::Rummager).to receive(:new)
        .with(Plek.new.find("rummager"))
        .and_return(rummager)

      expect(rummager).not_to receive(:add_document)
        .with(anything, "/finder-without-content-id", anything)

      expect(rummager).to receive(:add_document)
        .with(anything, "/finder-with-content-id", anything)

      RummagerFinderPublisher.new(metadata, logger: test_logger).call
    end
  end
end
