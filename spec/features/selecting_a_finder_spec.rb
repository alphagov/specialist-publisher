require 'spec_helper'

RSpec.feature 'The root specialist-publisher page', type: :feature do
  context 'when logged in as a GDS editor' do
    let(:fields) { %i(content_id base_path description details public_updated_at publication_state title update_type) }
    before do
      publishing_api_has_content([], document_type: 'manual', fields: fields, per_page: 10000)
      log_in_as_editor(:gds_editor)
    end

    it 'has one finder link per document schema' do
      visit '/'

      click_link('Finders')

      json_schema_count = Dir['lib/documents/schemas/*.json'].length
      expect(page).to have_css(
        '.dropdown-menu.finders li',
        count: json_schema_count
      )
    end

    it 'has a finder for DFID research outputs' do
      visit '/'

      click_link('Finders')

      expect(page).to have_text('DFID Research Outputs')
    end
  end
end
