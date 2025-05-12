class FinderSchemaPolicy < ApplicationPolicy
  def can_request_new_finder?
    gds_editor?
  end
end
