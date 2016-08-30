class AttachmentPolicy < ApplicationPolicy
  def new?
    gds_editor? || departmental_editor? || writer?
  end

  alias_method :create?, :new?
  alias_method :edit?, :new?
  alias_method :update?, :new?
  alias_method :delete?, :new?
end
