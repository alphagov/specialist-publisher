require "rails_helper"

RSpec.describe "publish rake tasks", type: :task do
  describe "publish:all" do
    let(:task) { Rake::Task["publish:all"] }
    before(:each) { task.reenable }

    it "errors if no document type is given" do
      expect { task.invoke("") }.to raise_error("No type given.")
    end

    it "calls publisher with the input document types" do
      expect(Publisher).to receive(:publish_all).with({ types: %w[abc def] })
      task.invoke("abc def")
    end
  end

  describe "publish:all_silent" do
    let(:task) { Rake::Task["publish:all_silent"] }
    before(:each) { task.reenable }

    it "errors if no document type is given" do
      expect { task.invoke("") }.to raise_error("No type given.")
    end

    it "calls publisher with the input document types" do
      expect(Publisher).to receive(:publish_all).with({ types: %w[abc def], disable_email_alert: true })
      task.invoke("abc def")
    end
  end
end
