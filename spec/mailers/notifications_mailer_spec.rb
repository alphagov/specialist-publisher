require "rails_helper"

RSpec.describe NotificationsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }
  let(:csv) { "Header one,Header two\r\nrow a value one,row a value two\r\nrow b value one,row b value two\r\n" }
  describe "document_list without a query" do
    let(:mail) { described_class.document_list(csv, user, BusinessFinanceSupportScheme, nil) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your exported list of Business Finance Support Schemes from GOV.UK")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['inside-government@digital.cabinet-office.gov.uk'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{user.name}")
      expect(mail.body.encoded).to match("CSV of Business Finance Support Schemes you requested from GOV.UK specialist publisher")
    end

    it "attaches the CSV" do
      expect(mail.attachments.first.filename).to eq 'document_list.csv'
      expect(mail.attachments.first.body.to_s).to eq csv
    end
  end

  describe "document_list with a query" do
    let(:mail) { described_class.document_list(csv, user, BusinessFinanceSupportScheme, 'startups') }

    it "renders the headers" do
      expect(mail.subject).to eq("Your exported list of Business Finance Support Schemes from GOV.UK")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['inside-government@digital.cabinet-office.gov.uk'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{user.name}")
      expect(mail.body.encoded).to match('CSV of Business Finance Support Schemes matching the query "startups" you requested from GOV.UK specialist publisher')
    end

    it "attaches the CSV" do
      expect(mail.attachments.first.filename).to eq 'document_list.csv'
      expect(mail.attachments.first.body.to_s).to eq csv
    end
  end
end
