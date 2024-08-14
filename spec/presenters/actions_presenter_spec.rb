require "spec_helper"

RSpec.describe ActionsPresenter do
  include AuthenticationControllerHelpers

  let(:payload) { FactoryBot.create(:cma_case) }
  let(:content_id) { payload["content_id"] }
  let(:locale) { payload["locale"] }

  let(:document) { SpecialistDocument::CmaCase.from_publishing_api(payload) }
  let(:user) { FactoryBot.create(:cma_editor) }
  let(:policy) { DocumentPolicy.new(user, SpecialistDocument::CmaCase) }

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
    specify { expect(subject.publish_text).to include("will email subscribers") }
    specify { expect(subject.publish_text).not_to include("major edit") }

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.publish_text).to include("don't have permission to publish") }
    end

    context "when the document is already published" do
      let(:payload) { FactoryBot.create(:cma_case, :published) }
      specify { expect(subject.publish_text).to include("no changes") }

      context "and the update_type is republish" do
        let(:payload) { FactoryBot.create(:cma_case, :published, update_type: "republish") }
        specify { expect(subject.publish_text).to include("no changes") }
      end
    end

    context "when the document is unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, :unpublished) }
      specify { expect(subject.publish_text).to include("create a new draft") }
    end

    context "when the document is redrafted" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted) }
      specify { expect(subject.publish_text).to include("major edit") }
      specify { expect(subject.publish_text).to include("will email subscribers") }
    end

    context "when the document is redrafted and the update_type is minor" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted, update_type: "minor") }
      specify { expect(subject.publish_text).to include("minor edit") }
      specify { expect(subject.publish_text).not_to include("will email subscribers") }
    end
  end

  describe "publish_alert" do
    specify { expect(subject.publish_alert).to include("will email subscribers to CMA Cases") }

    context "when the update_type is minor" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted, update_type: "minor") }
      specify { expect(subject.publish_alert).to include("minor edit") }
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

  describe "unpublish_text" do
    let(:payload) { FactoryBot.create(:cma_case, :published) }

    specify { expect(subject.unpublish_text).to include("removed from the site") }

    context "when the document is a draft" do
      let(:payload) { FactoryBot.create(:cma_case) }
      specify { expect(subject.unpublish_text).to include("never been published") }
    end

    context "when the document is redrafted" do
      let(:payload) { FactoryBot.create(:cma_case, :redrafted) }
      specify { expect(subject.unpublish_text).to include("publish the draft first") }
    end

    context "when the document is already unpublished" do
      let(:payload) { FactoryBot.create(:cma_case, publication_state: "unpublished") }
      specify { expect(subject.unpublish_text).to include("already unpublished") }
    end

    context "when the user does not have editor permissions" do
      let(:user) { FactoryBot.create(:cma_writer) }
      specify { expect(subject.unpublish_text).to include("don't have permission to unpublish") }
    end
  end

  describe "unpublish_alert" do
    specify { expect(subject.unpublish_alert).to include("Are you sure") }
  end

  describe "unpublish_path" do
    specify { expect(subject.unpublish_path).to eq("/cma-cases/#{content_id}:#{locale}/unpublish") }
  end
end
