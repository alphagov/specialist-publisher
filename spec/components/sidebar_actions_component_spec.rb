require "rails_helper"

RSpec.describe SidebarActionsComponent, type: :component do
  describe "edit button" do
    it "should show on draft document" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Edit document")
    end

    it "should show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Edit document")
    end

    it "should show on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Edit document")
    end

    it "should show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Edit document")
    end
  end

  describe "publish button" do
    it "should show on draft document" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Publish document")
    end

    it "should not show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Publish document")
    end

    it "should show on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Publish document")
    end

    it "should not show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Publish document")
    end

    it "should not show when user not allowed to publish" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Publish document")
    end
  end

  describe "unpublish button and text" do
    it "should not show on draft document" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
    end

    it "should show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Unpublish document")
    end

    it "should not show on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
    end

    it "should not show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
    end

    it "should not show when user not allowed to unpublish" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
    end
  end

  describe "discard draft link" do
    it "should show on draft document" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Delete draft")
    end

    it "should not show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Delete draft")
    end

    it "should show on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Delete draft")
    end

    it "should not show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Delete draft")
    end

    it "should not show when user not allowed to discard draft" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Delete draft")
    end
  end

  describe "notices" do
    it "should not show on draft document" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_selector(".app-view-summary__sidebar-notices")
    end

    it "should not show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_selector(".app-view-summary__sidebar-notices")
    end

    it "should show unpublishing notice on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_text("The document cannot be unpublished because it has a draft. You need to publish the draft first.")
    end

    it "should not show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_selector(".app-view-summary__sidebar-notices")
    end

    it "should show permissions notice when publish button should show but user not allowed to publish" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_text("You don't have permission to publish this document.")
    end

    it "should show permissions notice when unpublish button should show but user not allowed to unpublish" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_text("You don't have permission to unpublish this document.")
    end

    it "should show permissions notice when delete draft button should show but user not allowed to delete draft" do
      content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_text("You don't have permission to delete this draft.")
    end

    it "should not show publish permissions notice when publish button doesn't show" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_text("You don't have permission to publish this document.")
    end

    it "should not show unpublish permissions notice when unpublish button doesn't show" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_text("You don't have permission to unpublish this document.")
    end

    it "should not show delete draft permissions notice when delete draft button doesn't show" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_text("You don't have permission to delete this draft.")
    end
  end
end
