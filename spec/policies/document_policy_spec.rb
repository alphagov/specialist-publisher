require 'spec_helper'

describe DocumentPolicy do
  let(:cma_organisation_id) { CmaCase.organisations.first }
  let(:gds_editor) { User.new(permissions: %w(signin gds_editor)) }
  let(:cma_departmental_editor) { User.new(permissions: %w(signin editor), organisation_content_id: cma_organisation_id) }
  let(:cma_writer) { User.new(permissions: ['signin'], organisation_content_id: cma_organisation_id) }

  permissions :index?, :show?, :new?, :create?, :edit?, :update? do
    it 'denies access to users from another organisation' do
      expect(described_class).not_to permit(cma_writer, AaibReport)
    end

    it 'grants access to users from the organisation to which the document belongs' do
      expect(described_class).to permit(cma_writer, CmaCase)
    end

    it 'grants access to users with GDS Editor permissions' do
      expect(described_class).to permit(gds_editor, CmaCase)
    end
  end

  permissions :publish? do
    it 'denies access to users without editors permissions' do
      expect(described_class).not_to permit(cma_writer, CmaCase)
    end

    it 'denies access to editors from another organisation' do
      expect(described_class).not_to permit(cma_departmental_editor, AaibReport)
    end

    it 'grants access to editors from the organisation to which the document belongs' do
      expect(described_class).to permit(cma_departmental_editor, CmaCase)
    end

    it 'grants access to users with GDS Editor permissions' do
      expect(described_class).to permit(gds_editor, CmaCase)
    end
  end
end
