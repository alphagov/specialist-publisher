require "rails_helper"

RSpec.describe NotificationsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }
  let(:csv) { "Header one,Header two\r\nrow a value one,row a value two\r\nrow b value one,row b value two\r\n" }
  let(:url) { "http://www.example.com/foo.csv" }
  describe "document_list without a query" do
    let(:mail) { described_class.document_list(url, user, BusinessFinanceSupportScheme, nil) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your exported list of Business Finance Support Schemes from GOV.UK")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["inside-government@digital.cabinet-office.gov.uk"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{user.name}")
      expect(mail.body.encoded).to match("You requested a CSV of Business Finance Support Schemes from GOV.UK specialist publisher")
    end

    it "does not attach a CSV" do
      expect(mail.attachments).to be_empty
    end

    it "contains a url" do
      expect(mail.body).to include "http://www.example.com/foo.csv"
    end
  end

  describe "document_list with a query" do
    let(:mail) { described_class.document_list(url, user, BusinessFinanceSupportScheme, "startups") }

    it "renders the headers" do
      expect(mail.subject).to eq("Your exported list of Business Finance Support Schemes from GOV.UK")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["inside-government@digital.cabinet-office.gov.uk"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{user.name}")
      expect(mail.body.encoded).to match('You requested a CSV of Business Finance Support Schemes matching the query "startups" from GOV.UK specialist publisher')
    end

    it "does not attach a CSV" do
      expect(mail.attachments).to be_empty
    end

    it "contains a url" do
      expect(mail.body).to include "http://www.example.com/foo.csv"
    end
  end
end
