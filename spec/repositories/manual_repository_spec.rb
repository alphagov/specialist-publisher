require "fast_spec_helper"

require "manual_repository"

describe ManualRepository do
  subject(:repo) {
    ManualRepository.new(
      collection: record_collection,
      factory: manual_factory,
      association_marshallers: association_marshallers,
    )
  }

  let(:record_collection) {
    double(:record_collection,
      find_or_initialize_by: nil,
    )
  }

  let(:association_marshallers) { [] }

  let(:manual_factory)  { double(:manual_factory, call: nil) }
  let(:manual_id) { double(:manual_id) }
  let(:manual_slug) { double(:manual_slug) }

  let(:manual)    { double(:manual, manual_attributes) }

  let(:manual_attributes) {
    {
      id: manual_id,
      title: "title",
      state: "draft",
      summary: "summary",
      body: "body",
      organisation_slug: "organisation_slug",
      slug: manual_slug,
      tags: []
    }
  }

  let(:manual_record) {
    double(
      :manual_record,
      manual_id: manual_id,
      new_or_existing_draft_edition: nil,
      organisation_slug: "organisation_slug",
      :"organisation_slug=" => nil,
      slug: manual_slug,
      :"slug=" => nil,
      latest_edition: nil,
      save!: nil,
      tags: [],
    )
  }

  let(:edition) { double(:edition, edition_messages) }
  let(:edition_messages) {
    edition_attributes.merge(
      :attributes= => nil,
    )
  }
  let(:edition_attributes) {
    {
      title: "title",
      summary: "summary",
      body: "body",
      updated_at: "yesterday",
      organisation_slug: "organisation_slug",
      state: "draft",
      slug: manual_slug,
      version_number: 1,
    }
  }

  it "supports the fetch interface" do
    expect(repo).to be_a_kind_of(Fetchable)
  end

  describe "#store" do
    let(:draft_edition) { double(:draft_edition, :attributes= => nil) }

    before do
      allow(record_collection).to receive(:find_or_initialize_by)
        .and_return(manual_record)

      allow(manual_record).to receive(:new_or_existing_draft_edition)
        .and_return(edition)
    end

    it "retrieves the manual record from the record collection" do
      repo.store(manual)

      expect(record_collection).to have_received(:find_or_initialize_by)
        .with(manual_id: manual_id)
    end

    it "retrieves a new or existing draft edition from the record" do
      repo.store(manual)

      expect(manual_record).to have_received(:new_or_existing_draft_edition)
    end

    it "updates the edition with the attributes from the object" do
      repo.store(manual)

      expect(edition).to have_received(:attributes=)
        .with(manual_attributes.slice(:title, :summary, :state, :body, :tags))
    end

    it "sets the slug" do
      repo.store(manual)

      expect(manual_record).to have_received(:slug=).with(manual_slug)
    end

    it "sets the organisation_slug" do
      repo.store(manual)

      expect(manual_record).to have_received(:organisation_slug=).with("organisation_slug")
    end

    it "saves the manual" do
      repo.store(manual)

      expect(manual_record).to have_received(:save!)
    end

    context "with an association_marshaller" do
      let(:association_marshallers) { [association_marshaller] }

      let(:association_marshaller) {
        double(:association_marshaller, dump: nil)
      }

      it "calls dump on each marshaller with the manual domain object and edition" do
        repo.store(manual)

        expect(association_marshaller).to have_received(:dump).with(manual, edition)
      end
    end
  end

  describe "#[]" do
    before do
      allow(record_collection).to receive(:find_by).and_return(manual_record)
      allow(manual_record).to receive(:latest_edition).and_return(edition)
      allow(manual_factory).to receive(:call).and_return(manual)
    end

    it "finds the manual record by manual id" do
      repo[manual_id]

      expect(record_collection).to have_received(:find_by)
        .with(manual_id: manual_id)
    end

    it "builds a new manual from the latest edition" do
      repo[manual_id]

      factory_arguments = edition_attributes.merge(id: manual_id)

      expect(manual_factory).to have_received(:call)
        .with(factory_arguments)
    end

    it "returns the built manual" do
      expect(repo[manual_id]).to be(manual)
    end

    context "with an association_marshaller" do
      let(:association_marshallers) { [association_marshaller] }

      let(:association_marshaller) {
        double(:association_marshaller, load: unmarshalled_manual)
      }

      let(:unmarshalled_manual) { double(:unmarshalled_manual) }

      it "calls load on each marshaller with the manual domain object and edition" do
        repo[manual_id]

        expect(association_marshaller).to have_received(:load).with(manual, edition)
      end

      it "returns the result of the marshaller" do
        expect(repo[manual_id]).to eq(unmarshalled_manual)
      end
    end
  end

  describe "#all" do
    before do
      allow(record_collection).to receive(:all_by_updated_at).and_return([manual_record])
      allow(manual_record).to receive(:latest_edition).and_return(edition)
    end

    it "retrieves all records from the collection" do
      repo.all

      expect(record_collection).to have_received(:all_by_updated_at)
    end

    it "builds a manual for each record" do
      repo.all.to_a

      factory_arguments = edition_attributes.merge(id: manual_id)

      expect(manual_factory).to have_received(:call).with(factory_arguments)
    end

    it "builds lazily" do
      repo.all

      expect(manual_factory).not_to have_received(:call)
    end

    it "returns the built manuals" do
      allow(manual_factory).to receive(:call).and_return(manual)

      expect(repo.all.to_a).to eq([manual])
    end
  end
end
