require 'spec_helper'

RSpec.describe ManualPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update? do
    it 'grants access to all user' do
      expect(described_class).to permit(User.new, :manual)
    end
  end

  describe ManualPolicy::Scope do
    let(:manual) { double(Manual) }
    subject(:scope) { ManualPolicy::Scope.new(user, manual) }

    context 'when the user is a gds_editor' do
      let(:user) { User.new(permissions: %w(signin gds_editor)) }

      it 'fetches all manuals' do
        expect(manual).to receive(:all)
        scope.resolve
      end
    end

    context 'when the user is a departmental editor' do
      let(:organisation_id) { 'department-of-manuals' }
      let(:user) { User.new(permissions: %w(signin editor), organisation_content_id: organisation_id) }

      it "fetches only the manuals that are associated with the user's organisation" do
        expect(manual).to receive(:where).with(organisation_content_id: organisation_id)
        scope.resolve
      end
    end

    context 'when the user is a departmental writer' do
      let(:organisation_id) { 'department-of-manuals' }
      let(:user) { User.new(permissions: ['signin'], organisation_content_id: organisation_id) }

      it "fetches only the manuals that are associated with the user's organisation" do
        expect(manual).to receive(:where).with(organisation_content_id: organisation_id)
        scope.resolve
      end
    end
  end
end
