require "rails_helper"

RSpec.describe RepublishService do
  let(:document) { FactoryBot.create(:cma_case) }
  let(:content_id) { document["content_id"] }
  let(:locale) { document["locale"] }

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

  shared_examples "transform put content" do |times|
    it "allows transforming the put content payload" do
      subject.call(content_id, locale) do |payload|
        payload[:title] = "Transformed title"
      end

      assert_publishing_api_put_content(
        content_id, request_json_includes("title" => "Transformed title"), times
      )
    end
  end

  context "when the document is a draft" do
    let(:document) do
      FactoryBot.create(:cma_case, :draft)
    end

    it "sends the document to the publishing api" do
      subject.call(content_id, locale)

      assert_publishing_api_put_content(content_id, does_not_use_republish_update_type)
      assert_publishing_api_patch_links(content_id)
    end

    it "does not speak to email alert api" do
      subject.call(content_id, locale)

      expect(WebMock).not_to have_requested(:post, /notifications/)
    end

    include_examples "transform put content", 1
  end

  context "when the document is redrafted" do
    let(:document) do
      FactoryBot.create(:cma_case, :redrafted)
    end

    it "sends the draft and live versions to the publishing api" do
      subject.call(content_id, locale)

      assert_publishing_api_put_content(content_id, does_not_use_republish_update_type)
      assert_publishing_api_put_content(content_id, uses_republish_update_type)
      assert_publishing_api_patch_links(content_id)
    end

    it "publishes the document" do
      subject.call(content_id, locale)

      assert_publishing_api_publish(content_id, uses_republish_update_type)
    end

    it "does not speak to email alert api" do
      subject.call(content_id, locale)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end

    include_examples "transform put content", 2
  end

  context "when the document is published" do
    let(:document) do
      FactoryBot.create(:cma_case, :published)
    end

    it "sends the document to the publishing api" do
      subject.call(content_id, locale)

      assert_publishing_api_put_content(content_id, uses_republish_update_type)
      assert_publishing_api_patch_links(content_id)
    end

    it "publishes the document" do
      subject.call(content_id, locale)

      assert_publishing_api_publish(content_id, uses_republish_update_type)
    end

    it "does not speak to email alert api" do
      subject.call(content_id, locale)

      expect(WebMock).not_to have_requested(:post, /notifications/)
    end

    include_examples "transform put content", 1
  end

  context "when the document is unpublished" do
    let(:document) do
      FactoryBot.create(:cma_case, :unpublished)
    end

    it "skips republishing of the document" do
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
      expect(WebMock).not_to have_requested(:put, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /publishing-api/)
      expect(WebMock).not_to have_requested(:post, /notifications/)
    end
  end
end
