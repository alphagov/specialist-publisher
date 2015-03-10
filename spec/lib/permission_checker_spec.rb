require "spec_helper"

describe PermissionChecker do
  let(:cma_writer)   { FactoryGirl.build(:cma_writer) }
  let(:dclg_editor)  { FactoryGirl.build(:dclg_editor) }
  let(:defra_editor) { FactoryGirl.build(:defra_editor) }
  let(:gds_editor)   { FactoryGirl.build(:gds_editor) }

  describe "#can_edit?" do
    context "a user who is not an editor" do
      subject(:checker) { PermissionChecker.new(cma_writer) }

      context "editing a manual" do
        it "allows editing" do
          expect(checker.can_edit?("manual")).to be true
        end
      end

      context "editing a non-manual format owned by their organisation" do
        it "allows editing" do
          expect(checker.can_edit?("cma_case")).to be true
        end
      end

      context "editing a non-manual format not owned by their organisation" do
        it "prevents editing" do
          expect(checker.can_edit?("maib_report")).to be false
        end
      end
    end

    context "a GDS editor" do
      subject(:checker) { PermissionChecker.new(gds_editor) }

      it "allows editing of any format" do
        expect(checker.can_edit?("tea_and_cake")).to be true
      end
    end
  end

  describe "#can_publish?" do
    context "a user who is not an editor" do
      subject(:checker) { PermissionChecker.new(cma_writer) }

      it "prevents publishing" do
        expect(checker.can_publish?("manual")).to be false
      end
    end

    context "an editor" do
      subject(:checker) { PermissionChecker.new(dclg_editor) }

      context "publishing a manual" do
        it "allows publishing" do
          expect(checker.can_publish?("manual")).to be true
        end
      end

      context "publishing a non-manual format owned by their organisation" do
        it "allows publishing" do
          expect(checker.can_publish?("esi_fund")).to be true
        end
      end

      context "publishing a non-manual format not owned by their organisation" do
        it "prevents publishing" do
          expect(checker.can_publish?("maib_report")).to be false
        end
      end
    end

    context "a GDS editor" do
      subject(:checker) { PermissionChecker.new(gds_editor) }

      it "allows publishing of any format" do
        expect(checker.can_publish?("tea_and_biscuits")).to be true
      end
    end
  end

  describe "#is_gds_editor?" do
    it "is true for a GDS editor" do
      checker = PermissionChecker.new(gds_editor)
      expect(checker.is_gds_editor?).to be true
    end

    it "is false for a non-GDS editor" do
      checker = PermissionChecker.new(dclg_editor)
      expect(checker.is_gds_editor?).to be false
    end
  end

  describe "multiple organisations owning a format" do
    let(:checkers) {
      [PermissionChecker.new(dclg_editor), PermissionChecker.new(defra_editor)]
    }

    it "allows members of all owning organisations to edit" do
      checkers.each do |checker|
        expect(checker.can_edit?("esi_fund")).to be true
      end
    end

    it "allows editors who are members of all owning organisations to publish" do
      checkers.each do |checker|
        expect(checker.can_publish?("esi_fund")).to be true
      end
    end
  end
end
