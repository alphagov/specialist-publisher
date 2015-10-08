class PermissionChecker
  GDS_EDITOR_PERMISSION = "gds_editor"
  EDITOR_PERMISSION = "editor"

  def self.owning_organisations_for_format(format)
    case format
    when "asylum_support_decision"
      ["first-tier-tribunal-asylum-support"]
    when "cma_case"
      ["competition-and-markets-authority"]
    when "aaib_report"
      ["air-accidents-investigation-branch"]
    when "international_development_fund"
      ["department-for-international-development"]
    when "drug_safety_update", "medical_safety_alert"
      ["medicines-and-healthcare-products-regulatory-agency"]
    when "employment_appeal_tribunal_decision"
      ["employment-appeal-tribunal"]
    when "employment_tribunal_decision"
      ["employment-tribunal"]
    when "esi_fund"
      %w(
        department-for-communities-and-local-government
        department-for-work-pensions
        department-for-environment-food-rural-affairs
        rural-payments-agency
      )
    when "maib_report"
      ["marine-accident-investigation-branch"]
    when "raib_report"
      ["rail-accident-investigation-branch"]
    when "countryside_stewardship_grant"
      ["natural-england"]
    when "tax_tribunal_decision"
      ["upper-tribunal-tax-and-chancery-chamber"]
    when "utaac_decision"
      ["upper-tribunal-administrative-appeals-chamber"]
    when "vehicle_recalls_and_faults_alert"
      ["driver-and-vehicle-standards-agency"]
    end
  end

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
    self.class.owning_organisations_for_format(format).include?(user.organisation_slug)
  end

end
