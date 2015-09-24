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

    context 'with preview_only false metadata and RAILS_ENV is "production"' do
      let(:metadata) do
        [
          {
            file: {
              "base_path" => "/finder-with-preview-only-true",
              "content_id" => SecureRandom.uuid,
              "name" => "finder with preview only true",
              "format" => "a_report_format",
              "format_name" => "a report format",
              "preview_only" => false,
            },
            timestamp: "2015-01-05T10:45:10.000+00:00",
          },
        ]
      end

      it "does publish finder" do
        rummager = double("rummager")

        production = ActiveSupport::StringInquirer.new("production")
        allow(Rails).to receive(:env).and_return(production)

        expect(GdsApi::Rummager).to receive(:new)
          .with(Plek.new.find("rummager"))
          .and_return(rummager)

        expect(rummager).to receive(:add_document)
          .with(anything, "/finder-with-preview-only-true", anything)

        RummagerFinderPublisher.new(metadata, logger: test_logger).call
      end
    end

    context "with preview_only true metadata" do
      let(:metadata) do
        [
          {
            file: {
              "base_path" => "/finder-with-preview-only-true",
              "name" => "finder with preview only true",
              "format" => "a_report_format",
              "format_name" => "a report format",
              "preview_only" => true,
            },
            timestamp: "2015-01-05T10:45:10.000+00:00",
          },
        ]
      end

      context 'and RAILS_ENV is not "production"' do
        it "publishes finder" do
          rummager = double("rummager")
          expect(GdsApi::Rummager).to receive(:new)
            .with(Plek.new.find("rummager"))
            .and_return(rummager)

          expect(rummager).to receive(:add_document)
            .with(anything, "/finder-with-preview-only-true", anything)

          RummagerFinderPublisher.new(metadata, logger: test_logger).call
        end
      end

      context 'and RAILS_ENV is "production"' do
        let(:metadata) do
          [
            {
              file: {
                "base_path" => "/finder-with-preview-only-true",
                "content_id" => SecureRandom.uuid,
                "name" => "finder with preview only true",
                "format" => "a_report_format",
                "format_name" => "a report format",
                "preview_only" => true,
              },
              timestamp: "2015-01-05T10:45:10.000+00:00",
            },
          ]
        end

        let(:rummager) { double("rummager") }

        before do
          production = ActiveSupport::StringInquirer.new("production")
          allow(Rails).to receive(:env).and_return(production)

          allow(GdsApi::Rummager).to receive(:new)
            .with(Plek.new.find("rummager"))
            .and_return(rummager)
        end

        context 'and GOVUK_APP_DOMAIN does not contain "preview"' do
          it "does not publish finder" do
            expect(rummager).not_to receive(:add_document)
              .with(anything, "/finder-with-preview-only-true", anything)

            RummagerFinderPublisher.new(metadata, logger: test_logger).call
          end
        end

        context 'and GOVUK_APP_DOMAIN contains "preview"' do
          it "publishes finder" do
            allow(ENV).to receive(:fetch).with("GOVUK_APP_DOMAIN", "").and_return("preview")
            expect(rummager).to receive(:add_document)
              .with(anything, "/finder-with-preview-only-true", anything)

            RummagerFinderPublisher.new(metadata, logger: test_logger).call
          end
        end
      end
    end
  end
end
