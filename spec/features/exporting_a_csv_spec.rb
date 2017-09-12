require 'rails_helper'

RSpec.feature 'Exporting a list of documents as CSV' do
  let(:documents) {
    3.times.map do |i|
      FactoryGirl.create(
        :business_finance_support_scheme,
        base_path: "/bfss/#{i}",
        title: "Scheme ##{i}"
      )
    end
  }
  let(:user) { FactoryGirl.create(:gds_editor) }
  let(:expected_csv) {
    CSV.generate do |csv|
      csv << BusinessFinanceSupportSchemeExportPresenter.header_row
      documents.each { |doc| csv << BusinessFinanceSupportSchemeExportPresenter.new(BusinessFinanceSupportScheme.from_publishing_api(doc)).row }
    end
  }

  before do
    log_in_as user

    publishing_api_has_content(documents, hash_including(document_type: BusinessFinanceSupportScheme.document_type))
  end

  scenario "I can export a list of documents and they are emailed to me" do
    visit "/#{BusinessFinanceSupportScheme.slug}"

    click_on 'Export document list to CSV'

    expect(page).to have_content "The following will be emailed to #{user.email}:"
    expect(page).to have_content 'All Business Finance Support Schemes'

    Sidekiq::Testing.inline! { click_on 'Export as CSV' }

    expect(page).to have_content 'The document list is being exported'

    last_email = ActionMailer::Base.deliveries.last
    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to have_content 'Your exported list of Business Finance Support Schemes from GOV.UK'

    expect(last_email.attachments.length).to eq 1
    attachment = last_email.attachments[0]
    expect(attachment.content_type).to start_with('text/comma-separated-values;')
    expect(attachment.filename).to eq 'document_list.csv'

    csv_body = attachment.body.to_s
    expect(csv_body).to eq expected_csv
  end
end
