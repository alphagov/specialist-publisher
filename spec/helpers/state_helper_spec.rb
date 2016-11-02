require "rails_helper"

RSpec.describe StateHelper, type: :helper do
  describe "#last_two_states" do
    it "pads the previous version when there is only one state history" do
      history_of_a_first_draft = { "1": "draft" }
      expect(last_two_states(history_of_a_first_draft)).to eq([nil, "draft"])
    end

    it "returns the last pair of states in an Array" do
      simple_state_history = { "1": "published", "2": "draft" }
      longer_state_history = { "9": "published", "10": "unpublished", "11": "draft" }
      expect(last_two_states(simple_state_history)).to eq(%w(published draft))
      expect(last_two_states(longer_state_history)).to eq(%w(unpublished draft))
    end
  end

  describe "#compose_state" do
    context "draft state" do
      let(:state_history) do
        { "1": "draft" }
      end
      it "returns the state in string" do
        expect(compose_state(state_history)).to eq("draft")
      end
    end

    context "published state" do
      let(:state_history) do
        { "1": "published" }
      end
      it "returns the state in string" do
        expect(compose_state(state_history)).to eq("published")
      end
    end

    context "unpublished state" do
      let(:state_history) do
        { "1": "published",
          "2": "unpublished" }
      end
      it "returns the state in string" do
        expect(compose_state(state_history)).to eq("unpublished")
      end
    end

    context "published with new draft state" do
      let(:state_history) do
        { "1": "published",
         "2": "draft" }
      end
      it "returns the state in string" do
        expect(compose_state(state_history)).to eq("published with new draft")
      end
    end

    context "unpublished with new draft state" do
      let(:state_history) do
        { "1": "unpublished",
         "2": "draft" }
      end
      it "returns the state in string" do
        expect(compose_state(state_history)).to eq("unpublished with new draft")
      end
    end
  end
end
