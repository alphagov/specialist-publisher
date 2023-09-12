module OrganisationsHelper
  def all_organisations
    @all_organisations ||= Organisation.all
  end

  def organisations_options
    all_organisations.map { |o| [o.title, o.content_id] }.sort_by { |title, _id| title.downcase.strip }
  end

  def organisations_options_with_all
    [["All organisations", "all"]].concat(organisations_options)
  end

  def selected_organisation_or_current(organisation)
    (organisation.presence || current_user.organisation_content_id)
  end

  def organisation_name(content_id)
    all_organisations.select { |o| o.content_id == content_id }.first&.title
  end
end
