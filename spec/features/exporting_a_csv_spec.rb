require "rails_helper"

RSpec.feature "Exporting a list of documents as CSV" do
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
      documents.each { |doc| csv << BusinessFinanceSupportSchemeExportPresenter.new(BusinessFinanceSupportScheme.from_publishing_api(doc)).row }
    end
  end

  before do
    log_in_as user

    stub_publishing_api_has_content(documents, hash_including(document_type: BusinessFinanceSupportScheme.document_type))

    Fog.mock!
    ENV["AWS_REGION"] = "eu-west-1"
    ENV["AWS_ACCESS_KEY_ID"] = "test"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test"
    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"

    # Create an S3 bucket so the code being tested can find it
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
    @directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"]) || connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"])
  end

  scenario "I can export a list of documents and they are emailed to me" do
    visit "/#{BusinessFinanceSupportScheme.slug}"

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
