require "spec_helper"

RSpec.describe ActionsPresenter do
  include AuthenticationControllerHelpers

  let(:payload) { FactoryBot.create(:cma_case) }
  let(:content_id) { payload["content_id"] }
  let(:locale) { payload["locale"] }

  let(:document) { CmaCase.from_publishing_api(payload) }
  let(:user) { FactoryBot.create(:cma_editor) }
  let(:policy) { DocumentPolicy.new(user, CmaCase) }

  subject { described_class.new(document, policy) }

  describe "edit_path" do
    specify { expect(subject.edit_path).to eq("/cma-cases/#{content_id}:#{locale}/edit") }
  end

  describe "publish_button_visible?" do
    specify { expect(subject.publish_button_visible?).to eq(true) }

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.publish_button_visible?).to eq(false) }
    end

    context "when the document is already published" do
      let(:payload) { FactoryBot.create(:cma_case, :published) }
      specify { expect(subject.publish_button_visible?).to eq(false) }

      context "and the update_type is republish" do
        let(:payload) { FactoryBot.create(:cma_case, :published, update_type: "republish") }
        specify { expect(subject.publish_button_visible?).to eq(false) }
      end
    end

    context "when the document is unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, :unpublished) }
      specify { expect(subject.publish_button_visible?).to eq(false) }
    end
  end

  describe "publish_text" do
    context "when the document is a new draft" do
      let(:payload) { FactoryBot.create(:cma_case, :draft) }
      specify { expect(subject.publish_text).to eq("<p>Publishing will email subscribers to CMA Cases.</p><p>Are you sure you want to publish this document?</p>") }
    end

    context "when the document is redrafted" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted) }
      specify { expect(subject.publish_text).to eq("<p>You are about to publish a major edit with a public change note. Publishing will email subscribers to CMA Cases.</p><p>Are you sure you want to publish this document?</p>") }
    end

    context "when the document is redrafted and the update_type is minor" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted, update_type: "minor") }
      specify { expect(subject.publish_text).to eq("<p>You are about to publish a minor edit.</p><p>Are you sure you want to publish this document?</p>") }
    end
  end

  describe "publish_text_legacy" do
    specify { expect(subject.publish_text_legacy).to include("will email subscribers") }
    specify { expect(subject.publish_text_legacy).not_to include("major edit") }

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.publish_text_legacy).to include("don't have permission to publish") }
    end

    context "when the document is already published" do
      let(:payload) { FactoryBot.create(:cma_case, :published) }
      specify { expect(subject.publish_text_legacy).to include("no changes") }

      context "and the update_type is republish" do
        let(:payload) { FactoryBot.create(:cma_case, :published, update_type: "republish") }
        specify { expect(subject.publish_text_legacy).to include("no changes") }
      end
    end

    context "when the document is unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, :unpublished) }
      specify { expect(subject.publish_text_legacy).to include("create a new draft") }
    end

    context "when the document is redrafted" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted) }
      specify { expect(subject.publish_text_legacy).to include("major edit") }
      specify { expect(subject.publish_text_legacy).to include("will email subscribers") }
    end

    context "when the document is redrafted and the update_type is minor" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted, update_type: "minor") }
      specify { expect(subject.publish_text_legacy).to include("minor edit") }
      specify { expect(subject.publish_text_legacy).not_to include("will email subscribers") }
    end
  end

  describe "publish_alert_legacy" do
    specify { expect(subject.publish_alert_legacy).to include("will email subscribers to CMA Cases") }

    context "when the update_type is minor" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted, update_type: "minor") }
      specify { expect(subject.publish_alert_legacy).to include("minor edit") }
    end
  end

  describe "publish_path" do
    specify { expect(subject.publish_path).to eq("/cma-cases/#{content_id}:#{locale}/publish") }
  end

  describe "unpublish_button_visible?" do
    let(:payload) { FactoryBot.create(:cma_case, :published) }

    specify { expect(subject.unpublish_button_visible?).to eq(true) }

    context "when the document is a draft" do
      let(:payload) { FactoryBot.create(:cma_case) }
      specify { expect(subject.unpublish_button_visible?).to eq(false) }
    end

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.unpublish_button_visible?).to eq(false) }
    end

    context "when the document is already unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, :unpublished) }
      specify { expect(subject.unpublish_button_visible?).to eq(false) }
    end
  end

  describe "unpublish_text_legacy" do
    let(:payload) { FactoryBot.create(:cma_case, :published) }

    specify { expect(subject.unpublish_text_legacy).to include("removed from the site") }

    context "when the document is a draft" do
      let(:payload) { FactoryBot.create(:cma_case) }
      specify { expect(subject.unpublish_text_legacy).to include("never been published") }
    end

    context "when the document is redrafted" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted) }
      specify { expect(subject.unpublish_text_legacy).to include("publish the draft first") }
    end

    context "when the document is already unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, publication_state: "unpublished") }
      specify { expect(subject.unpublish_text_legacy).to include("already unpublished") }
    end

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.unpublish_text_legacy).to include("don't have permission to unpublish") }
    end
  end

  describe "unpublish_alert_legacy" do
    specify { expect(subject.unpublish_alert_legacy).to include("Are you sure") }
  end

  describe "unpublish_path" do
    specify { expect(subject.unpublish_path).to eq("/cma-cases/#{content_id}:#{locale}/unpublish") }
  end
end
