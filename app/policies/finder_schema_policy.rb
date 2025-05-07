class FinderSchemaPolicy < ApplicationPolicy
  def index?
    document_type_editor? || gds_editor? || departmental_editor? || writer?
  end

  def can_request_new_finder?
    gds_editor?
  end
end
