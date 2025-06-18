class DocumentPolicy < ApplicationPolicy
  def index?
    document_type_editor? || gds_editor? || departmental_editor? || writer?
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :show?, :index?
  alias_method :destroy?, :index? # used only by AttachmentsController
  alias_method :confirm_delete?, :index? # used only by AttachmentsController

  # TODO: move these into the FinderSchemaPolicy and add associated tests
  def can_request_edits_to_finder?
    publish?
  end
  alias_method :summary?, :can_request_edits_to_finder?
  alias_method :edit_facets?, :can_request_edits_to_finder?
  alias_method :update_facets?, :can_request_edits_to_finder?
  alias_method :edit_metadata?, :can_request_edits_to_finder?
  alias_method :update_metadata?, :can_request_edits_to_finder?
  alias_method :zendesk?, :can_request_edits_to_finder?

  def publish?
    document_type_editor? || gds_editor? || departmental_editor?
  end

  alias_method :confirm_unpublish?, :publish?
  alias_method :unpublish?, :publish?
  alias_method :confirm_publish?, :publish?
  alias_method :confirm_discard?, :publish?
  alias_method :discard?, :publish?

private

  def user_organisation_owns_document_type?
    record.schema_organisations.include?(user.organisation_content_id) ||
      record.schema_editing_organisations.include?(user.organisation_content_id)
  end

  def departmental_editor?
    user_organisation_owns_document_type? && user.permissions.include?("editor")
  end

  def writer?
    user_organisation_owns_document_type?
  end

  def document_type_editor?
    user.permissions.include?("#{record.name.underscore}_editor")
  end
end
