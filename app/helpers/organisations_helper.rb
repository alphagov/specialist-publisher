module OrganisationsHelper
  def organisations_options
    Organisation.all.map { |o| [o.title, o.content_id] }.sort_by { |title, _id| title.downcase.strip }
  end

  def organisations_options_with_all
    [["All organisations", "all"]].concat(organisations_options)
  end

  def selected_organisation_or_current(organisation)
    (organisation.presence || current_user.organisation_content_id)
  end
end
