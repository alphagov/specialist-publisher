class PermissionChecker
  GDS_EDITOR_PERMISSION = "gds_editor"

  def initialize(user)
    @user = user
  end

  def can_edit?(format)
    is_gds_editor? || user_organisation_owns_format?(format)
  end

private
  attr_reader :user

  def is_gds_editor?
    user.has_permission?(GDS_EDITOR_PERMISSION)
  end

  def user_organisation_owns_format?(format)
    user.organisation_slug == owning_organisation_for_format(format)
  end

  def owning_organisation_for_format(format)
    case format
    when "cma_case"
      "competition-and-markets-authority"
    when "aaib_report"
      "air-accidents-investigation-branch"
    end
  end
end
