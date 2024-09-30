class DocumentPolicy < ApplicationPolicy
  def index?
    document_type_editor? || gds_editor? || departmental_editor? || writer?
  end

  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :show?, :index?
  # FIXME: fix this, attachments are using the wrong policy
  alias_method :destroy?, :index?

  def can_request_edits_to_finder?
    # TODO: figure out who should be allowed to do what RE administrating finders
    publish?
  end
  alias_method :index_of_admin_forms?, :can_request_edits_to_finder?
  alias_method :edit_metadata?, :can_request_edits_to_finder?
  alias_method :save_metadata?, :can_request_edits_to_finder?
  alias_method :edit_facets?, :can_request_edits_to_finder?
  alias_method :save_facets?, :can_request_edits_to_finder?

  def publish?
    document_type_editor? || gds_editor? || departmental_editor?
  end

  alias_method :unpublish?, :publish?
  alias_method :discard?, :publish?
end
