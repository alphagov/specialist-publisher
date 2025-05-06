module OrganisationsHelper
  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end

  def selected_organisation_or_current(organisation)
    organisation.presence || current_user.organisation_content_id
  end

  def organisations_select_options(selected_organisation_content_id = nil)
    all_organisations.map { |organisation|
      {
        text: organisation.title,
        value: organisation.content_id,
        selected: organisation.content_id == selected_organisation_content_id
      }
    }.sort_by { |option| option[:text].downcase.strip }
  end

private

  def all_organisations
    @all_organisations ||= Organisation.all
  end
end