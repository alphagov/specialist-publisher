class ApplicationPolicy
  attr_reader :user, :document_class

  def initialize(user, document_class)
    @user = user
    @document_class = document_class
  end

  def user_organisation_owns_document_type?
    document_class.schema_organisations.include?(user.organisation_content_id) ||
      document_class.schema_editing_organisations.include?(user.organisation_content_id)
  end

  def departmental_editor?
    user_organisation_owns_document_type? && user.permissions.include?("editor")
  end

  def writer?
    user_organisation_owns_document_type?
  end

  delegate :gds_editor?, to: :user

  def document_type_editor?
    user.permissions.include?("#{document_class.name.underscore}_editor")
  end
end
