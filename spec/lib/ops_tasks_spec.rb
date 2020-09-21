require "spec_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe OpsTasks do
  include GdsApi::TestHelpers::PublishingApi

  let(:payload) { FactoryBot.create(:cma_case) }
  let(:content_id) { payload["content_id"] }
  let(:locale) { payload["locale"] }

  before do
    stub_publishing_api_has_item(payload)
  end

  describe "#discard" do
    it "sends a discard draft request to the publishing api" do
      stub_publishing_api_discard_draft(content_id)

      subject.discard(content_id, locale)

      assert_publishing_api_discard_draft(content_id)
    end
  end

  describe "#email" do
    it "sends a notification request to the email alert api" do
      stub_email_alert_api_accepts_content_change

      subject.email(content_id, locale)

      assert_email_alert_api_content_change_created
    end
  end

  describe "#set_public_updated_at" do
    describe "when the document is live" do
      let(:payload) do
        FactoryBot.create(:cma_case, publication_state: "published")
      end

      before do
        stub_any_publishing_api_put_content
        stub_any_publishing_api_publish
      end

      it "publishes a new draft with an updated public_updated_at" do
        subject.set_public_updated_at(content_id, locale, "2016-01-01 12:34")

        assert_publishing_api_put_content(
          content_id,
          request_json_includes(
            "public_updated_at" => "2016-01-01T12:34:00.000+00:00",
            "update_type" => "republish",
          ),
        )

        assert_publishing_api_publish(
          content_id,
          request_json_includes("update_type" => "republish"),
        )
      end

      it "it uses Time.zone.now if the timestamp is set to 'now'" do
        Timecop.freeze(2016, 7, 8) do
          subject.set_public_updated_at(content_id, locale, "now")
        end

        assert_publishing_api_put_content(
          content_id,
          request_json_includes("public_updated_at" => "2016-07-08T00:00:00.000+01:00"),
        )
      end
    end

    describe "when the document is not live" do
      let(:payload) do
        FactoryBot.create(:cma_case, publication_state: "draft")
      end

      it "throws a helpful error" do
        expect {
          subject.set_public_updated_at(content_id, locale, "now")
        }.to raise_error(/cannot be updated/)
      end
    end
  end
end
