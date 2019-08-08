require "rails_helper"

RSpec.describe DocumentListExportWorker do
  describe "perform" do
    let(:user) { FactoryBot.create(:gds_editor) }
    let(:documents) do
      [
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: '/bfss/1',
          title: 'Scheme #1'
        ),
        FactoryBot.create(
          :business_finance_support_scheme,
          base_path: '/bfss/2',
          title: 'Scheme #2'
        )
      ]
    end

    it 'raises an error if the user does not have permission to see the document type' do
      user.update_attributes(permissions: %w[signin])
      expect {
        subject.perform(BusinessFinanceSupportScheme.slug, user.id, nil)
      }.to raise_error Pundit::NotAuthorizedError
    end

    it 'fetches every document of the supplied type and turns them into csv' do
      stub_finding_documents(documents)
      documents.each do |document|
        csv_presenter = double(BusinessFinanceSupportSchemeExportPresenter)
        expect(BusinessFinanceSupportSchemeExportPresenter).to receive(:new).with(document).and_return(csv_presenter)
        expect(csv_presenter).to receive(:row).and_return []
      end
      allow(subject).to receive(:send_mail)
      subject.perform(BusinessFinanceSupportScheme.slug, user.id, nil)
    end

    it 'sends mail with CSV to user' do
      stub_finding_documents(documents)
      csv_data = "my,csv\nfile,is\ngreat,really\n"
      allow(subject).to receive(:generate_csv).and_return csv_data

      expect(NotificationsMailer).to receive(:document_list).with(csv_data, user, BusinessFinanceSupportScheme, nil).and_return(double(ActionMailer::MessageDelivery, deliver_now: true))

      subject.perform(BusinessFinanceSupportScheme.slug, user.id, nil)
    end
  end

  def stub_finding_documents(documents)
    yielder = allow(AllDocumentsFinder).to receive(:find_each)
    documents.each do |doc|
      yielder.and_yield(doc)
    end
  end
end
