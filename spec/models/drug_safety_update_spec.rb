require "fast_spec_helper"
require "drug_safety_update"

RSpec.describe DrugSafetyUpdate do

  let(:document) {
    double(:document,
      publish!: true,
      withdraw!: true,
      extra_fields: {
        first_published_at: first_published_at,
      },
    )
  }
  subject(:drug_safety_update) { DrugSafetyUpdate.new(document) }

  describe "#publish!" do
    before do
      allow(document).to receive(:update)
    end

    context "when there is not a first_published_at" do
      let(:first_published_at) { "" }

      it "calls publish on the specialist document" do
        drug_safety_update.publish!
        expect(document).to have_received(:publish!)
      end

      it "sets the first_published_at on the document to current time" do
        time = Time.now
        Timecop.freeze(time) do
          drug_safety_update.publish!
          expect(document).to have_received(:update).with(hash_including(extra_fields: { first_published_at: time }))
        end
      end
    end

    context "when there is a first_published_at" do
      let(:first_published_at) { double(:first_published_at) }

      it "calls publish on the specialist document" do
        drug_safety_update.publish!
        expect(document).to have_received(:publish!)
      end

      it "does not set the first_published_at on the document" do
        drug_safety_update.publish!
        expect(document).to_not have_received(:update)
      end
    end
  end

  describe "#withdraw!" do
    let(:first_published_at) { double(:first_published_at) }

    before do
      allow(document).to receive(:update)
    end

    it "calls withdraw on the specialist document" do
      drug_safety_update.withdraw!
      expect(document).to have_received(:withdraw!)
    end

    it "sets the first_published_at on the document to nil" do
      drug_safety_update.withdraw!
      expect(document).to have_received(:update).with(hash_including(extra_fields: { first_published_at: nil }))
    end
  end

end
