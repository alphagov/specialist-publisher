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

  describe "base_path:edit_all" do
    let(:output) { StringIO.new }
    let(:task) { Rake::Task["base_path:edit_all"] }
    let(:document_type) { "veterans_support_organisation" }
    let(:schema_base_path) { "/veteran-support-organisations" }
    let(:finder_content_id) { "finder-content-id" }
    let(:shell) { instance_double(Thor::Shell::Basic, yes?: true, say_error: nil) }
    let(:publishing_api) { double("publishing_api") }
    let(:report) do
      DocumentReslugger::Report.new(["/veteran-support-organisations/foo"], [], [], [])
    end
    let(:reslugger) { instance_double(DocumentReslugger, reslug_all: report) }

    before do
      $stdout = output
      task.reenable
      allow(Thor::Shell::Basic).to receive(:new).and_return(shell)
      allow(DocumentReslugger).to receive(:new).with(document_type, schema_base_path).and_return(reslugger)
      allow(FinderSchema).to receive(:load_from_schema)
        .with("veterans_support_organisations")
        .and_return(double(base_path: schema_base_path, content_id: finder_content_id))
      allow(Services).to receive(:publishing_api).and_return(publishing_api)
      stub_finder(publication_state: "published", base_path: schema_base_path)
    end

    after { $stdout = STDOUT }

    def stub_finder(publication_state:, base_path:)
      allow(publishing_api).to receive(:get_content).with(finder_content_id).and_return(
        double(to_h: { "publication_state" => publication_state, "base_path" => base_path }),
      )
    end

    it "reslugs every document of the type after confirmation" do
      task.invoke(document_type)

      expect(DocumentReslugger).to have_received(:new).with(document_type, schema_base_path)
      expect(reslugger).to have_received(:reslug_all)
    end

    it "prints a report of the results" do
      task.invoke(document_type)

      expect(output.string).to include("Published 1:")
      expect(output.string).to include("/veteran-support-organisations/foo")
    end

    it "does not reslug when the user does not confirm" do
      allow(shell).to receive(:yes?).and_return(false)

      task.invoke(document_type)

      expect(reslugger).not_to have_received(:reslug_all)
      expect(shell).to have_received(:say_error).with("Aborted")
    end

    it "does not reslug when the finder does not exist" do
      allow(publishing_api).to receive(:get_content).with(finder_content_id)
        .and_raise(GdsApi::HTTPNotFound.new(404))

      task.invoke(document_type)

      expect(shell).not_to have_received(:yes?)
      expect(reslugger).not_to have_received(:reslug_all)
      expect(shell).to have_received(:say_error).with(/does not exist/)
    end

    it "does not reslug when the finder is only on the draft stack" do
      stub_finder(publication_state: "draft", base_path: schema_base_path)

      task.invoke(document_type)

      expect(shell).not_to have_received(:yes?)
      expect(reslugger).not_to have_received(:reslug_all)
      expect(shell).to have_received(:say_error).with(/not published to the live stack/)
    end

    it "does not reslug when the published finder does not match the schema" do
      stub_finder(publication_state: "published", base_path: "/support-for-veterans")

      task.invoke(document_type)

      expect(shell).not_to have_received(:yes?)
      expect(reslugger).not_to have_received(:reslug_all)
      expect(shell).to have_received(:say_error).with(/must be published at/)
    end
  end
end
