class ManualSectionAttachmentPolicy < ApplicationPolicy
  def new?
    true
  end

  alias_method :create?, :new?
  alias_method :edit?, :new?
  alias_method :update?, :new?
end
