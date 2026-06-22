require "rails_helper"

RSpec.describe "base_path rake tasks", type: :task do
  describe "base_path:edit" do
    let(:output) { StringIO.new }
    let(:task) { Rake::Task["base_path:edit"] }
    let(:content_id) { SecureRandom.uuid }
    let(:locale) { "en" }
    let(:new_base_path) { "/new-finder/example-document" }

    let(:document) do
      instance_double(
        Document,
        base_path: "/old-finder/example-document",
        :base_path= => nil,
        :update_type= => nil,
        save: true,
        publish: true,
      )
    end

    before do
      $stdout = output
      task.reenable
    end

    after { $stdout = STDOUT }

    it "creates a draft at the new base_path" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)

      task.invoke(content_id, locale, new_base_path)

      expect(document).to have_received(:base_path=).with(new_base_path)
      expect(document).to have_received(:update_type=).with("minor")
      expect(document).to have_received(:save)
    end

    it "does not publish when no publish argument is given" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)

      task.invoke(content_id, locale, new_base_path)

      expect(document).not_to have_received(:publish)
    end

    it "publishes the new draft when publish is 'true'" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)

      task.invoke(content_id, locale, new_base_path, "true")

      expect(document).to have_received(:update_type=).with("minor")
      expect(document).to have_received(:publish)
    end

    it "does not publish when publish is not 'true'" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)

      task.invoke(content_id, locale, new_base_path, "false")

      expect(document).not_to have_received(:publish)
    end

    it "aborts without publishing when the save fails" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)
      allow(document).to receive(:save).and_return(false)
      allow(document).to receive(:errors).and_return(
        instance_double(ActiveModel::Errors, full_messages: ["Base path is invalid"]),
      )

      expect { task.invoke(content_id, locale, new_base_path, "true") }.to raise_error(SystemExit)
      expect(document).not_to have_received(:publish)
    end

    it "aborts when the publish fails" do
      allow(Document).to receive(:find).with(content_id, locale).and_return(document)
      allow(document).to receive(:publish).and_return(false)
      allow(document).to receive(:errors).and_return(
        instance_double(ActiveModel::Errors, full_messages: ["conflicts with content_id"]),
      )

      expect { task.invoke(content_id, locale, new_base_path, "true") }.to raise_error(SystemExit)
    end
  end
end
