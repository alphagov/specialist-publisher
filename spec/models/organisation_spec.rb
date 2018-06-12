require "spec_helper"

RSpec.describe Organisation do
  describe "initialize" do
    subject(:instance) do
      Organisation.new("content_id" => "12345", "title" => "Org")
    end

    it "populates content_id" do
      expect(instance.content_id).to eq("12345")
    end

    it "populates title" do
      expect(instance.title).to eq("Org")
    end
  end

  describe ".all" do
    let(:p1) do
      [
        { "content_id" => "12345", "title" => "First org" },
        { "content_id" => "67890", "title" => "Second org" },
      ]
    end

    let(:p2) do
      [
        { "content_id" => "09876", "title" => "Third org" },
        { "content_id" => "54321", "title" => "Fourth org" },
      ]
    end

    before do
      # organisations are memoized on the Organisation class
      Object.send(:remove_const, :Organisation)
      load "organisation.rb"

      allow(Services.publishing_api).to receive(:get_content_items)
        .with(a_hash_including(page: 1))
        .and_return("results" => p1, "pages" => 2)
      allow(Services.publishing_api).to receive(:get_content_items)
        .with(a_hash_including(page: 2))
        .and_return("results" => p2, "pages" => 2)
    end

    it "returns results as Organisations" do
      expect(Organisation.all.size).to eq(4)
      expect(Organisation.all.first.title).to eq("First org")
      expect(Organisation.all.last.title).to eq("Fourth org")
    end
  end
end
