module OrganisationsHelper
  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end

  def selected_organisation_or_current(organisation)
    organisation.presence || current_user.organisation_content_id
  end

private

  def all_organisations
    @all_organisations ||= Organisation.all
  end
end