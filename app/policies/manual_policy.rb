class ManualPolicy < ApplicationPolicy
  def index?
    true
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :show?, :index?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.gds_editor?
        scope.all
      else
        scope.where(organisation_content_id: user.organisation_content_id)
      end
    end
  end
end
