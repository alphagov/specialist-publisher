class ManualSectionPolicy < ApplicationPolicy
  def new?
    true
  end

  alias_method :create?, :new?
  alias_method :edit?, :new?
  alias_method :update?, :new?
  alias_method :show?, :new?
end
