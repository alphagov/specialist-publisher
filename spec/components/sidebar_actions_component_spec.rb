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
      expect(page).to have_text("The document has never been published.")
    end

    it "should show on published document" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to have_link("Unpublish document")
      expect(page).to have_text("The document will be removed from the site. It will still be possible to edit and publish a new version.")
    end

    it "should not show on published with draft document" do
      content_item = FactoryBot.create(:cma_case, :redrafted, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
      expect(page).to have_text("The document cannot be unpublished because it has a draft. You need to publish the draft first.")
    end

    it "should not show on unpublished document" do
      content_item = FactoryBot.create(:cma_case, :unpublished, title: "Example CMA Case")
      user = FactoryBot.create(:cma_editor)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
      expect(page).to have_text("The document is already unpublished.")
    end

    it "should not show when user not allowed to publish" do
      content_item = FactoryBot.create(:cma_case, :published, title: "Example CMA Case")
      user = FactoryBot.create(:cma_writer)
      document = DocumentBuilder.build(CmaCase, content_item)
      render_inline(described_class.new(document, user))

      expect(page).to_not have_link("Unpublish document")
      expect(page).to have_text("You don't have permission to unpublish this document.")
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
end
