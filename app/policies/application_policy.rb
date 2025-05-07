class ApplicationPolicy
  attr_reader :user, :subject

  def initialize(user, subject)
    @user = user
    @subject = subject
  end

  def departmental_editor?
    user_organisation_owns_document_type? && user.permissions.include?("editor")
  end

  def writer?
    user_organisation_owns_document_type?
  end

  delegate :gds_editor?, to: :user

  def document_type_editor?
    user.permissions.include?("#{subject.name.underscore}_editor")
  end
end
