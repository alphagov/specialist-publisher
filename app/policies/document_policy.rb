class DocumentPolicy
  attr_reader :user, :document_class

  def initialize(user, document_class)
    @user = user
    @document_class = document_class
  end

  def user_organisation_owns_document_type?
    document_class.organisations.include?(user.organisation_content_id)
  end

  def departmental_editor
    user_organisation_owns_document_type? && user.permissions.include?('editor')
  end

  def writer
    user_organisation_owns_document_type?
  end

  def gds_editor
    user.gds_editor?
  end

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
end
