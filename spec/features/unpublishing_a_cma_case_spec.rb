require 'spec_helper'

RSpec.feature 'Unpublishing a CMA case', type: :feature do
  let(:cma_content_id) { 'c1b89646-bb11-487b-971a-4603bdd95b1d' }
  let(:gone_content_id) { '44c3e7d3-2ec8-429f-bf5d-45c3125cd8ae' }

  let(:published_cma_case) { Payloads.cma_case_content_item('content_id' => cma_content_id) }
  let(:expected_withdraw_payload) do
    {
      content_id: gone_content_id,
      base_path: published_cma_case['base_path'],
      schema_name: 'gone',
      document_type: 'gone',
      format: 'gone',
      publishing_app: 'specialist-publisher',
      routes: [{
        path: published_cma_case['base_path'],
        type: 'exact'
               }]
    }
  end

  before do
    log_in_as_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_publishing_api_publish(gone_content_id, {})

    allow(SecureRandom).to receive(:uuid).and_return(gone_content_id)

    publishing_api_has_item(published_cma_case)
  end

  scenario 'from the show page' do
    visit "/cma-cases/#{cma_content_id}"

    click_button "Withdraw document"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Withdrawn Example CMA Case")

    assert_publishing_api_put_content(gone_content_id, expected_withdraw_payload)
    assert_publishing_api_publish(gone_content_id)
  end
end
