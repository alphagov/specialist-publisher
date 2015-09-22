require "spec_helper"

RSpec.describe "Saving invalid documents", type: :feature do
  before do
    login_as(:aaib_editor)
    stub_organisation_details(GDS::SSO.test_user.organisation_slug)
  end

  let(:title) { "A title" }
  let(:summary) { "A summary" }
  let(:body) { "A body" }
  let(:date_of_occurrence) { "2015-01-01" }

  let(:create_report) do
    create_aaib_report({ title: title,
                         summary: summary,
                         body: body,
                         date_of_occurrence: date_of_occurrence
                       },
                      save: true,
                      publish: true)
  end

  describe "saving edits to a published AAIB report" do
    before do
      create_report
      go_to_edit_page_for_aaib_report(title)
    end

    context "when valid" do
      before do
        fill_in :aaib_report_body, with: "A different body"
        check :aaib_report_minor_update
        click_button "Save"
        click_button "Publish"
      end

      it "should publish the new body" do
        go_to_show_page_for_aaib_report(title)
        expect(page).to have_content "published"
        expect(page).to have_content "A different body"
      end

      it "should be the only document" do
        go_to_aaib_report_index
        expect(page).to have_css "ul.document-list li.document", count: 1
      end
    end

    context "when invalid" do
      before do
        fill_in :aaib_report_body, with: "A different body"
        uncheck :aaib_report_minor_update
        click_button "Save"
      end

      it "should not publish the new body" do
        go_to_show_page_for_aaib_report(title)
        expect(page).to have_content "published"
        expect(page).to have_content "A body"
      end

      it "should be the only document" do
        go_to_aaib_report_index
        expect(page).to have_css "ul.document-list li.document", count: 1
      end

      describe "fixing the validation errors" do
        before do
          check :aaib_report_minor_update
          click_button "Save"
        end

        it "should persist the new body" do
          go_to_show_page_for_aaib_report(title)
          expect(page).to have_content "draft"
          expect(page).to have_content "A different body"
        end

        it "should be the only document" do
          go_to_aaib_report_index
          expect(page).to have_css "ul.document-list li.document", count: 1
        end
      end
    end
  end
end
