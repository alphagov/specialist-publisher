require "rails_helper"

RSpec.describe DocumentPublisher do
  it "updates the timestamp of the changenote prior to publishing" do
    payload = FactoryBot.create(:cma_case)
    stub_publishing_api_has_item(payload)
    document = DocumentBuilder.build(CmaCase, payload)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_publishing_api_publish(payload["content_id"], {})
    stub_email_alert_api_accepts_content_change

    current_time = "2016-12-03T16:59:13+00:00"
    Timecop.freeze(Time.zone.parse(current_time)) do
      expect(document.public_updated_at).to eq("2015-11-16T11:53:30+00:00")
      DocumentPublisher.publish(document)
      expect(document.public_updated_at).to eq(current_time)
    end
  end
end
