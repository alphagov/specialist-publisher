require "fast_spec_helper"

require "manual"

describe Manual do
  subject(:manual) {
    Manual.new(
      id: id,
      slug: slug,
      title: title,
      summary: summary,
      body: body,
      organisation_slug: organisation_slug,
      state: state,
      updated_at: updated_at,
      tags: []
    )
  }

  let(:id) { double(:id) }
  let(:updated_at) { double(:updated_at) }
  let(:title) { double(:title) }
  let(:summary) { double(:summary) }
  let(:body) { double(:body) }
  let(:organisation_slug) { double(:organisation_slug) }
  let(:state) { double(:state) }
  let(:slug) { double(:slug) }

  it "rasies an error without an ID" do
    expect {
      Manual.new({})
    }.to raise_error
  end

  describe "#publish" do
    it "returns self" do
      expect(manual.publish).to be(manual)
    end

    let(:state) { "draft" }

    it "sets the state to 'published'" do
      manual.publish

      expect(manual.state).to eq("published")
    end

    it "yields to the block" do
      expect { |block|
        manual.publish(&block)
      }.to yield_with_no_args
    end
  end

  describe "#attributes" do
    it "returns a hash of attributes" do
      expect(manual.attributes).to eq(
        id: id,
        title: title,
        slug: slug,
        summary: summary,
        body: body,
        organisation_slug: organisation_slug,
        state: state,
        updated_at: updated_at,
        version_number: 0,
        tags: [],
      )
    end
  end

  describe "#update" do
    it "returns self" do
      expect(manual.update({})).to be(manual)
    end

    context "with allowed attirbutes" do
      let(:new_title) { double(:new_title) }
      let(:new_summary) { double(:new_summary) }
      let(:new_organisation_slug) { double(:new_organisation_slug) }
      let(:new_state) { double(:new_state) }

      it "updates with the given attributes" do
        manual.update(
          title: new_title,
          summary: new_summary,
          organisation_slug: new_organisation_slug,
          state: new_state,
        )

        expect(manual.title).to eq(new_title)
        expect(manual.summary).to eq(new_summary)
        expect(manual.organisation_slug).to eq(new_organisation_slug)
        expect(manual.state).to eq(new_state)
      end

      it "doesn't nil out attributes not in list" do
        manual.update({})

        expect(manual.title).to eq(title)
        expect(manual.summary).to eq(summary)
        expect(manual.organisation_slug).to eq(organisation_slug)
        expect(manual.state).to eq(state)
      end
    end

    context "with disallowed attributes" do
      let(:new_id) { double(:new_id) }
      let(:new_updated_at) { double(:new_updated_at) }

      it "does not update the attributes" do
        manual.update(
          id: new_id,
          updated_at: new_updated_at,
        )

        expect(manual.id).to eq(id)
        expect(manual.updated_at).to eq(updated_at)
      end
    end
  end
end
