require 'spec_helper'

RSpec.feature 'The root specialist-publisher page', type: :feature do
  context 'when logged in as a GDS editor' do
    let(:fields) { %i(content_id base_path description details public_updated_at publication_state title update_type) }
    before do
      publishing_api_has_content([], document_type: 'manual', fields: fields, per_page: Manual.max_numbers_of_manuals)
      log_in_as_editor(:gds_editor)
    end

    it 'grants access to view all finders including pre-production' do
      visit '/'

      click_link('Finders')

      count = Dir['lib/documents/schemas/*.json'].length
      expect(page).to have_css('.dropdown-menu:nth-of-type(1) li', count: count)
    end

    it 'does not have a finder for pre_production finder DFID research outputs' do
      visit '/'

      click_link('Finders')

      expect(page).not_to have_text('Employment appeal tribunal decision')
    end

    it 'does have a finder for non pre_production finder CMA Cases' do
      visit '/'

      click_link('Finders')

      expect(page).to have_text('CMA Cases')
    end
  end
end
