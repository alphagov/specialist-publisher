class FinderSchemaPolicy < ApplicationPolicy
  def index?
    document_type_editor? || gds_editor? || departmental_editor? || writer?
  end

  def can_request_new_finder?
    gds_editor?
  end

private

  def user_organisation_owns_document_type?
    subject.organisations.include?(user.organisation_content_id) ||
      subject.editing_organisations.include?(user.organisation_content_id)
  end
end
