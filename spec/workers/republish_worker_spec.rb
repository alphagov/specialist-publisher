require "rails_helper"

RSpec.describe RepublishWorker do
  let(:document) { FactoryGirl.create(:cma_case) }
  let(:content_id) { document["content_id"] }

  let(:republish_matcher) {
    request_json_includes("update_type" => "republish")
  }

  before do
    stub_any_publishing_api_call
    stub_any_rummager_post

    publishing_api_has_item(document)
  end

  %w(draft redrafted).each do |publication_state|
    context "when the publication_state is '#{publication_state}'" do
      let(:document) {
        FactoryGirl.create(:cma_case, publication_state: publication_state)
      }

      it "sends the document to the publishing api" do
        subject.perform(content_id)

        assert_publishing_api_put_content(content_id, republish_matcher)
        assert_publishing_api_patch_links(content_id)
      end

      it "does not publish the document" do
        subject.perform(content_id)

        expect(WebMock).not_to have_requested(:post, /publish/)
      end

      it "does not speak to rummager" do
        subject.perform(content_id)

        expect(WebMock).not_to have_requested(:post, /search/)
      end

      it "does not speak to email alert api" do
        subject.perform(content_id)

        expect(WebMock).not_to have_requested(:post, /notifications/)
      end
    end
  end

  context "when the document is live" do
    let(:document) {
      FactoryGirl.create(:cma_case, publication_state: "live")
    }

    it "sends the document to the publishing api" do
      subject.perform(content_id)

      assert_publishing_api_put_content(content_id, republish_matcher)
      assert_publishing_api_patch_links(content_id)
    end

    it "publishes the document" do
      subject.perform(content_id)

      assert_publishing_api_publish(content_id, republish_matcher)
    end

    it "sends the document to rummager" do
      subject.perform(content_id)

      assert_rummager_posted_item({})
    end

    it "does not speak to email alert api" do
      subject.perform(content_id)

      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end

  context "when the document is unpublished" do
    let(:document) {
      FactoryGirl.create(:cma_case, publication_state: "unpublished")
    }

    it "skips republishing of the document" do
      expect {
        subject.perform(content_id)
      }.to output(/Skipped republishing/).to_stdout

      expect(WebMock).not_to have_requested(:put, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /publishing-api/)
      expect(WebMock).not_to have_requested(:any, /rummager/)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end

  context "when the document is in any other state" do
    let(:document) {
      FactoryGirl.create(:cma_case, publication_state: "unrecognised")
    }

    it "skips republishing of the document" do
      expect {
        subject.perform(content_id)
      }.to output(/Skipped republishing/).to_stdout

      expect(WebMock).not_to have_requested(:put, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /publishing-api/)
      expect(WebMock).not_to have_requested(:any, /rummager/)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end
end
