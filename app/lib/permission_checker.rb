class PermissionChecker
  GDS_EDITOR_PERMISSION = "gds_editor"
  EDITOR_PERMISSION = "editor"

  def initialize(user)
    @user = user
  end

  def can_edit?(format)
    is_gds_editor? || can_access_format?(format)
  end

  def can_publish?(format)
    is_gds_editor? || is_editor? && can_access_format?(format)
  end

  def can_withdraw?(format)
    can_publish?(format)
  end

  def is_gds_editor?
    user.has_permission?(GDS_EDITOR_PERMISSION)
  end

private
  attr_reader :user

  def is_editor?
    user.has_permission?(EDITOR_PERMISSION)
  end

  def can_access_format?(format)
    format == "manual" || user_organisation_owns_format?(format)
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
    when "international_development_fund"
      "department-for-international-development"
    when "drug_safety_update", "medical_safety_alert"
      "medicines-and-healthcare-products-regulatory-agency"
    when "maib_report"
      "marine-accident-investigation-branch"
    when "raib_report"
      "rail-accident-investigation-branch"
    when "countryside_stewardship_grant"
      "department-for-environment-food-rural-affairs"
    end
  end
end
