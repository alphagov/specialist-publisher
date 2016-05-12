require 'spec_helper'

RSpec.describe DocumentPolicy do
  let(:allowed_organisation_id) { 'department-of-serious-business' }
  let(:not_allowed_organisation_id) { 'ministry-of-funk' }
  let(:gds_editor) { User.new(permissions: %w(signin gds_editor)) }
  let(:departmental_editor) { User.new(permissions: %w(signin editor), organisation_content_id: allowed_organisation_id) }
  let(:departmental_writer) { User.new(permissions: ['signin'], organisation_content_id: allowed_organisation_id) }

  let(:document_type) {
    Class.new(Document) do
      cattr_accessor :organisations
    end
  }

  let(:allowed_document_type) {
    document_type.tap do |dt|
      dt.organisations = [allowed_organisation_id]
    end
  }

  let(:not_allowed_document_type) {
    document_type.tap do |dt|
      dt.organisations = [not_allowed_organisation_id]
    end
  }

  permissions :index?, :show?, :new?, :create?, :edit?, :update? do
    it 'denies access to users from another organisation' do
      expect(described_class).not_to permit(departmental_writer, not_allowed_document_type)
    end

    it 'grants access to users from the organisation to which the document belongs' do
      expect(described_class).to permit(departmental_writer, allowed_document_type)
    end

    it 'grants access to users with GDS Editor permissions' do
      expect(described_class).to permit(gds_editor, allowed_document_type)
    end
  end

  permissions :publish? do
    it 'denies access to users without editors permissions' do
      expect(described_class).not_to permit(departmental_writer, allowed_document_type)
    end

    it 'denies access to editors from another organisation' do
      expect(described_class).not_to permit(departmental_editor, not_allowed_document_type)
    end

    it 'grants access to editors from the organisation to which the document belongs' do
      expect(described_class).to permit(departmental_editor, allowed_document_type)
    end

    it 'grants access to users with GDS Editor permissions' do
      expect(described_class).to permit(gds_editor, allowed_document_type)
    end
  end
end
