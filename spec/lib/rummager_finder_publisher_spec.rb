require "spec_helper"
require "rummager_finder_publisher"

describe RummagerFinderPublisher do
  let(:rummager) { double(:rummager) }

  let(:test_logger) { Logger.new(nil) }

  describe "#call" do
    describe "publishing finders" do
      let(:metadata) {
        [
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
          },
        ]
      }

      it "uses GdsApi::Rummager" do
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
    end

    context "when the finder isn't `pre_production`" do
      let(:metadata) {
        [
          {
            file: {
              "base_path" => "/not-pre-production-finder",
              "content_id" => SecureRandom.uuid,
              "name" => "finder with pre-production true",
              "format" => "a_report_format",
              "format_name" => "a report format",
              "pre_production" => false,
            },
            timestamp: "2015-01-05T10:45:10.000+00:00",
          },
        ]
      }

      it "publishes finder" do
        expect(GdsApi::Rummager).to receive(:new)
          .with(Plek.new.find("rummager"))
          .and_return(rummager)

        expect(rummager).to receive(:add_document)
          .with(anything, "/not-pre-production-finder", anything)

        RummagerFinderPublisher.new(metadata, logger: test_logger).call
      end
    end

    context "when the finder is `pre_production`" do
      let(:metadata) {
        [
          {
            file: {
              "base_path" => "/pre-production-finder",
              "content_id" => SecureRandom.uuid,
              "name" => "finder with pre-production true",
              "format" => "a_report_format",
              "format_name" => "a report format",
              "pre_production" => true,
            },
            timestamp: "2015-01-05T10:45:10.000+00:00",
          },
        ]
      }

      context "and the app is configured to publish pre-production finders" do
        before do
          SpecialistPublisher::Application.config
            .publish_pre_production_finders = true
        end

        after do
          SpecialistPublisher::Application.config
            .publish_pre_production_finders = false
        end

        it "publishes finder" do
          expect(GdsApi::Rummager).to receive(:new)
            .with(Plek.new.find("rummager"))
            .and_return(rummager)

          expect(rummager).to receive(:add_document)
            .with(anything, "/pre-production-finder", anything)

          RummagerFinderPublisher.new(metadata, logger: test_logger).call
        end
      end

      context "and is not configured to publish pre-production finders" do
        it "does not publish finder" do
          expect(rummager).not_to receive(:add_document)
            .with(anything, "/pre-production-finder", anything)

          RummagerFinderPublisher.new(metadata, logger: test_logger).call
        end
      end
    end
  end
end
