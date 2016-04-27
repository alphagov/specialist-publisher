require 'spec_helper'

describe ManualPolicy do
  permissions :index?, :show?, :new?, :create?, :edit?, :update? do
    it 'grants access to all user' do
      expect(described_class).to permit(User.new, :manual)
    end
  end
end
