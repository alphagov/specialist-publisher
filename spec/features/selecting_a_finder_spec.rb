require 'spec_helper'

RSpec.feature 'The root specialist-publisher page', type: :feature do
  context 'when logged in as a GDS editor' do
    before do
      publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
      publishing_api_has_content([], hash_including(document_type: AaibReport.document_type))
      log_in_as_editor(:gds_editor)
    end

    it 'grants access to view all finders including pre-production' do
      visit '/'

      click_link('AAIB Reports', match: :first)

      count = Dir['lib/documents/schemas/*.yml'].length
      expect(page).to have_css('.dropdown-menu:nth-of-type(1) li', count: count)
    end

    it 'selects and navigates to cma case finder' do
      visit '/'

      expect(page).to have_selector("h1", text: "AAIB Reports")

      click_link('AAIB Reports', match: :first)

      expect(page).to have_text('CMA Cases')

      click_link('CMA Cases')

      expect(page).to have_text('Add another CMA Case')
    end

    it 'has a finder for DFID research outputs' do
      visit '/'

      click_link('AAIB Reports', match: :first)

      expect(page).to have_text('DFID Research Outputs')
    end
  end

  context 'when logged in as a CMA editor' do
    before do
      publishing_api_has_content([], hash_including(document_type: CmaCase.document_type))
      log_in_as_editor(:cma_editor)
    end

    it 'displays only the CMA Cases finder' do
      visit '/'

      expect(page).to have_selector("h1", text: "CMA Cases")

      expect(page).to have_text('CMA Cases')

      expect(page).to have_css('.navbar-nav li a', count: 1)

      click_link('CMA Cases')

      expect(page).to have_content('Add another CMA Case')
    end
  end
end
