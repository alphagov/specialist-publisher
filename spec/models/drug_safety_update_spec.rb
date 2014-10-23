require "fast_spec_helper"
require "drug_safety_update"

RSpec.describe DrugSafetyUpdate do

  let(:document) {
    double(:document,
      publish!: true,
      extra_fields: {
        published_at: published_at,
      },
    )
  }
  subject(:drug_safety_update) { DrugSafetyUpdate.new(document) }

  describe "#publish!" do
    before do
      allow(document).to receive(:update)
    end

    context "when there is not a published_at" do
      let(:published_at) { "" }

      it "calls publish on the specialist document" do
        drug_safety_update.publish!
        expect(document).to have_received(:publish!)
      end

      it "sets the published_at on the document to current time" do
        time = Time.now
        Timecop.freeze(time) do
          drug_safety_update.publish!
          expect(document).to have_received(:update).with(hash_including(extra_fields: { published_at: time }))
        end
      end
    end

    context "when there is a published_at" do
      let(:published_at) { double(:published_at) }

      it "calls publish on the specialist document" do
        drug_safety_update.publish!
        expect(document).to have_received(:publish!)
      end

      it "does not set the published_at on the document" do
        drug_safety_update.publish!
        expect(document).to_not have_received(:update)
      end
    end
  end

end
