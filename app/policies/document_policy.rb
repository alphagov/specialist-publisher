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

  alias_method :unpublish?, :publish?

  def pre_production_formats
    PRE_PRODUCTION
  end

  def removed_pre_production?
    !pre_production_formats.include?(document_class.document_type)
  end

  def user_organisation_owns_document_type?
    document_class.organisations.include?(user.organisation_content_id) && removed_pre_production?
  end

  def departmental_editor
    user_organisation_owns_document_type? && user.permissions.include?('editor')
  end

  def writer
    user_organisation_owns_document_type?
  end

  def gds_editor
    removed_pre_production? && user.gds_editor?
  end
end
