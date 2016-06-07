class DocumentPolicy < ApplicationPolicy
  def index?
    gds_editor || departmental_editor || writer
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :show?, :index?

  def publish?
    gds_editor || departmental_editor
  end

  alias_method :withdraw?, :publish?
end
