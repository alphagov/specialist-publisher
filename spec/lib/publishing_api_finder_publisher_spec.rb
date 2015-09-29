require "spec_helper"
require "publishing_api_finder_publisher"

describe PublishingApiFinderPublisher do
  describe "#call" do

    let(:schema) {
      {
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
      }
    }

    def make_metadata(base_path, overrides = {})
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

      metadata
    end

    def make_finder(base_path, overrides = {})
      {
        schema: schema,
        metadata: make_metadata(base_path, overrides),
        timestamp: "2015-01-05T10:45:10.000+00:00",
      }
    end

    let(:publishing_api) { double("publishing-api") }

    let(:test_logger) { Logger.new(nil) }

    before do
      allow(GdsApi::PublishingApi).to receive(:new)
        .with(Plek.new.find("publishing-api"))
        .and_return(publishing_api)
    end

    describe "publishing finders" do
      let(:finders) {
        [
          make_finder("/first-finder", "signup_content_id" => SecureRandom.uuid),
          make_finder("/second-finder"),
        ]
      }

      it "uses GdsApi::PublishingApi" do
        expect(publishing_api).to receive(:put_content_item)
          .with("/first-finder", be_valid_against_schema("finder"))

         # This should be validated against an email-signup schema if one gets created
        expect(publishing_api).to receive(:put_content_item)
          .with("/first-finder/email-signup", anything)

        expect(publishing_api).to receive(:put_content_item)
          .with("/second-finder", be_valid_against_schema("finder"))

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder has a `phase`" do
      let(:finders) {
        [
          make_finder("/finder-with-phase", "phase" => "beta"),
        ]
      }

      it "publishes finder" do
        expect(publishing_api).to receive(:put_content_item)
          .with("/finder-with-phase", be_valid_against_schema("finder"))

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder isn't `pre_production`" do
      let(:finders) {
        [
          make_finder("/not-pre-production-finder", "pre_production" => false),
        ]
      }

      it "publishes finder" do
        expect(publishing_api).to receive(:put_content_item)
          .with("/not-pre-production-finder", anything)

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder is `pre_production`" do
      let(:finders) {
        [
          make_finder("/pre-production-finder", "pre_production" => true),
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
          expect(publishing_api).to receive(:put_content_item)
            .with("/pre-production-finder", anything)

          PublishingApiFinderPublisher.new(finders, logger: test_logger).call
        end
      end

      context "and is not configured to publish pre-production finders" do
        it "doesn't publish the finder" do
          expect(publishing_api).not_to receive(:put_content_item)
            .with("/pre-production-finder", anything)

          PublishingApiFinderPublisher.new(finders, logger: test_logger).call
        end
      end
    end
  end
end
