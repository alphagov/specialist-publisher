require "rails_helper"

RSpec.describe RepublishWorker do
  let(:document) { FactoryBot.create(:cma_case) }
  let(:content_id) { document["content_id"] }

  let(:uses_republish_update_type) do
    request_json_includes("update_type" => "republish")
  end

  let(:does_not_use_republish_update_type) do
    request_json_includes("update_type" => "major")
  end

  before do
    stub_any_publishing_api_call

    stub_publishing_api_has_item(document)
  end

  %i[draft redrafted].each do |publication_state|
    context "when the publication_state is '#{publication_state}'" do
      let(:document) do
        FactoryBot.create(:cma_case, publication_state)
      end

      it "sends the document to the publishing api" do
        subject.perform(content_id)

        assert_publishing_api_put_content(content_id, does_not_use_republish_update_type)
        assert_publishing_api_patch_links(content_id)
      end

      it "does not publish the document" do
        subject.perform(content_id)

        expect(WebMock).not_to have_requested(:post, /publish/)
      end

      it "does not speak to email alert api" do
        subject.perform(content_id)

        expect(WebMock).not_to have_requested(:post, /notifications/)
      end
    end
  end

  context "when the document is published" do
    let(:document) do
      FactoryBot.create(:cma_case, :published)
    end

    it "sends the document to the publishing api" do
      subject.perform(content_id)

      assert_publishing_api_put_content(content_id, uses_republish_update_type)
      assert_publishing_api_patch_links(content_id)
    end

    it "publishes the document" do
      subject.perform(content_id)

      assert_publishing_api_publish(content_id, uses_republish_update_type)
    end

    it "does not speak to email alert api" do
      subject.perform(content_id)

      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end

  context "when the document is unpublished" do
    let(:document) do
      FactoryBot.create(:cma_case, :unpublished)
    end

    it "skips republishing of the document" do
      expect {
        subject.perform(content_id)
      }.to output(/Skipped republishing/).to_stdout

      expect(WebMock).not_to have_requested(:put, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end

  context "when the document is in any other state" do
    let(:document) do
      FactoryBot.create(:cma_case, publication_state: "unrecognised")
    end

    it "skips republishing of the document" do
      expect {
        subject.perform(content_id)
      }.to output(/Skipped republishing/).to_stdout

      expect(WebMock).not_to have_requested(:put, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end
end
