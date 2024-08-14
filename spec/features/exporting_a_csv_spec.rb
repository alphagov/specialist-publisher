require "rails_helper"

RSpec.feature "Exporting a list of documents as CSV" do
  let(:stubbed_client) { Aws::S3::Client.new(stub_responses: true) }

  let(:documents) do
    3.times.map do |i|
      FactoryBot.create(
        :business_finance_support_scheme,
        base_path: "/bfss/#{i}",
        title: "Scheme ##{i}",
      )
    end
  end
  let(:user) { FactoryBot.create(:gds_editor) }
  let(:expected_csv) do
    CSV.generate do |csv|
      csv << BusinessFinanceSupportSchemeExportPresenter.header_row
      documents.each { |doc| csv << BusinessFinanceSupportSchemeExportPresenter.new(SpecialistDocument::BusinessFinanceSupportScheme.from_publishing_api(doc)).row }
    end
  end

  before do
    log_in_as user

    stub_publishing_api_has_content(documents, hash_including(document_type: SpecialistDocument::BusinessFinanceSupportScheme.document_type))

    stubbed_client = Aws::S3::Client.new(stub_responses: true)
    allow(Aws::S3::Client).to receive(:new).and_return(stubbed_client)

    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"
  end

  scenario "I can export a list of documents and they are emailed to me" do
    visit "/#{SpecialistDocument::BusinessFinanceSupportScheme.admin_slug}"

    click_on "Export document list to CSV"

    expect(page).to have_content "The following will be emailed to #{user.email}:"
    expect(page).to have_content "All Business Finance Support Schemes"

    Sidekiq::Testing.inline! { click_on "Export as CSV" }

    expect(page).to have_content "The document list is being exported"

    last_email = ActionMailer::Base.deliveries.last
    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to have_content "Your exported list of Business Finance Support Schemes from GOV.UK"

    expect(last_email.attachments.length).to eq 0
    expect(last_email.body).to have_content "http://specialist-publisher.dev.gov.uk/export"
  end
end
