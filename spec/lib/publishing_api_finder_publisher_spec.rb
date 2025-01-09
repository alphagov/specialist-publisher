require "spec_helper"

RSpec.describe PublishingApiFinderPublisher do
  describe "#call" do
    def make_file(base_path, overrides = {})
      underscore_name = base_path.sub("/", "")
      name = underscore_name.humanize
      {
        "target_stack" => "live",
        "base_path" => base_path,
        "name" => name,
        "content_id" => SecureRandom.uuid,
        "format" => "#{underscore_name}_format",
        "logo_path" => "http://example.com/logo.png",
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
      }.merge(overrides)
    end

    def make_finder(base_path, overrides = {})
      {
        file: make_file(base_path, overrides),
        timestamp: Time.zone.parse("2015-01-05T10:45:10.000+00:00"),
      }
    end

    let(:publishing_api) { double("publishing-api") }

    let(:test_logger) { Logger.new(nil) }

    before do
      allow(Services).to receive(:publishing_api)
        .and_return(publishing_api)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
    end

    describe "publishing finders" do
      let(:finders) do
        [
          make_finder("/first-finder", "email_filter_options" => { "signup_content_id" => SecureRandom.uuid }),
          make_finder("/second-finder"),
        ]
      end

      it "uses GdsApi::PublishingApi" do
        stub_publishing_api_publish(finders[0][:file]["content_id"], {})
        stub_publishing_api_publish(finders[0][:file]["email_filter_options"], {})
        stub_publishing_api_publish(finders[1][:file]["content_id"], {})

        expect(publishing_api).to receive(:put_content)
          .with(finders[0][:file]["content_id"], be_valid_against_publisher_schema("finder"))
        expect(publishing_api).to receive(:patch_links)
          .with(finders[0][:file]["content_id"], anything)
        expect(publishing_api).to receive(:publish)
          .with(finders[0][:file]["content_id"])

        # This should be validated against an email-signup schema if one gets created
        expect(publishing_api).to receive(:put_content)
          .with(finders[0][:file]["email_filter_options"], anything)
        expect(publishing_api).to receive(:patch_links)
          .with(finders[0][:file]["email_filter_options"], anything)
        expect(publishing_api).to receive(:publish)
          .with(finders[0][:file]["email_filter_options"])

        expect(publishing_api).to receive(:put_content)
          .with(finders[1][:file]["content_id"], be_valid_against_publisher_schema("finder"))
        expect(publishing_api).to receive(:patch_links)
          .with(finders[1][:file]["content_id"], anything)
        expect(publishing_api).to receive(:publish)
          .with(finders[1][:file]["content_id"])

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder has a `phase`" do
      let(:finders) { [make_finder("/finder-with-phase", "phase" => "beta")] }

      let(:content_id) { finders[0]["content_id"] }

      before do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links
        stub_publishing_api_publish(content_id, {})
      end

      it "publishes finder" do
        expect(publishing_api).to receive(:put_content)
          .with(finders[0][:file]["content_id"], be_valid_against_publisher_schema("finder"))
        expect(publishing_api).to receive(:patch_links)
          .with(finders[0][:file]["content_id"], anything)
        expect(publishing_api).to receive(:publish)
          .with(finders[0][:file]["content_id"])

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder is set to deploy to live target_stack" do
      let(:finders) { [make_finder("/live-finder", "target_stack" => "live")] }

      let(:content_id) { finders[0][:file]["content_id"] }

      before do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_patch_links
        stub_publishing_api_publish(content_id, {})
      end

      it "publishes finder" do
        expect(publishing_api).to receive(:put_content)
          .with(content_id, be_valid_against_publisher_schema("finder"))
        expect(publishing_api).to receive(:patch_links)
          .with(content_id, anything)
        expect(publishing_api).to receive(:publish)
          .with(content_id)

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    shared_examples "only updates draft stack" do
      let(:content_id) { finders[0][:file]["content_id"] }

      before { stub_any_publishing_api_put_content }

      it "updates the finder content but does not publish it" do
        expect(publishing_api).to receive(:put_content).with(content_id, be_valid_against_publisher_schema("finder"))
        expect(publishing_api).not_to receive(:patch_links)
        expect(publishing_api).not_to receive(:publish)

        PublishingApiFinderPublisher.new(finders, logger: test_logger).call
      end
    end

    context "when the finder is set to deploy to draft target_stack" do
      let(:finders) { [make_finder("/draft-finder", "target_stack" => "draft")] }
      include_examples "only updates draft stack"
    end

    context "when the finder is set to deploy to unknown target_stack" do
      let(:finders) { [make_finder("/draft-finder", "target_stack" => "unknown")] }
      include_examples "only updates draft stack"
    end

    context "when the target_stack is not defined" do
      let(:finders) { [make_finder("/draft-finder", "target_stack" => nil)] }
      include_examples "only updates draft stack"
    end
  end
end
