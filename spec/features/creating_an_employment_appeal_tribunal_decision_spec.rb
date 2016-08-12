require 'spec_helper'

RSpec.feature "Creating a Employment appeal tribunal decision", type: :feature do
  let(:fields)            { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }
  let(:research_output)   { FactoryGirl.create(:employment_appeal_tribunal_decision) }
  let(:content_id)        { research_output['content_id'] }
  let(:public_updated_at) { research_output['public_updated_at'] }

  context 'in development' do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)
      log_in_as_editor(:gds_editor)

      Timecop.freeze(Time.parse(public_updated_at))
      allow(SecureRandom).to receive(:uuid).and_return(content_id)

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      publishing_api_has_item(research_output)
    end

    scenario "with valid data" do
      visit "/eat-decisions/new"
      title = "Example Employment appeal tribunal decision"
      summary = "This is the summary of an example Employment appeal tribunal decision"

      expect(page.status_code).to eq(200)

      fill_in "Title", with: title
      fill_in "Summary", with: summary
      fill_in "Body", with: ("## Header" + ("\n\nThis is the long body of an example Employment appeal tribunal decision" * 10))
      select "Age Discrimination", from: "Tribunal decision categories"
      select "Contract of Employment - Apprenticeship", from: "Tribunal decision sub categories"
      fill_in "Tribunal decision decision date", with: "2013-01-01"
      select "Not landmark", from: "Tribunal decision landmark"
      fill_in "Hidden indexable content", with: "hidden text goes here"


      expect(page).to have_css('div.govspeak-help')
      expect(page).to have_content('To add an attachment, please save the draft first.')

      click_button "Save as draft"

      expect(page.status_code).to eq(200)
      assert_publishing_api_put_content(content_id)

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Created Example Employment appeal tribunal decision")
    end

    scenario "with no data" do
      visit "/eat-decisions/new"

      expect(page.status_code).to eq(200)

      click_button "Save as draft"

      expect(page.status_code).to eq(422)

      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Summary can't be blank")
      expect(page).to have_content("Body can't be blank")
      expect(page).to have_content("Tribunal decision categories can't be blank")
      expect(page).to have_content("Tribunal decision sub categories can't be blank")
      expect(page).to have_content("Tribunal decision decision date")

      expect(page).to_not have_content("Hidden indexable content can't be blank")
    end

    scenario "with invalid data" do
      visit "/eat-decisions/new"

      expect(page.status_code).to eq(200)

      fill_in "Title", with: "Example Employment appeal tribunal decision"
      fill_in "Summary", with: "This is the summary of an example Employment appeal tribunal decision"
      fill_in "Body", with: "<script>alert('hello')</script>"

      click_button "Save as draft"

      expect(page.status_code).to eq(422)

      expect(page).to have_content("Body cannot include invalid Govspeak")
    end
  end

  context 'in production' do
    before do
      allow(Rails.env).to receive(:development?).and_return(false)
      log_in_as_editor(:gds_editor)
    end

    context "when logged in as an editor" do
      before { log_in_as_editor(:editor) }

      scenario "not seeing pre-production formats" do
        visit "/eat-decisions/new"
        expect(page.current_path).to eq("/manuals")
      end
    end

    context "when logged in as a gds_editor" do
      before { log_in_as_editor(:gds_editor) }

      scenario "seeing pre-production formats" do
        visit "/eat-decisions/new"
        expect(page.current_path).to eq("/eat-decisions/new")
      end
    end
  end
end
